import 'dart:io';

import 'package:test/test.dart';
import 'package:zuraffa_session/zuraffa_session.dart';

void main() {
  late Directory tempDir;
  late Directory storeDir;
  late SessionManager manager;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('zuraffa_session_mgr_');
    storeDir = Directory('${tempDir.path}/store');
    manager = SessionManager(port: FileSessionStore(storeDir));
  });

  tearDown(() async {
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  PortableSession sessionFor(String id, String origin) => PortableSession(
    id: id,
    name: 'N-$id',
    origin: origin,
    createdAt: 1,
    updatedAt: 2,
    cookies: List.generate(
      2,
      (i) => CookieEntry(
        name: 'c$i',
        value: 'v$i',
        domain: origin,
        path: '/',
        expiresAt: null,
        secure: true,
        httpOnly: false,
      ),
    ),
    storage: [
      StorageEntry(
        key: 'k',
        value: 'v-$id',
        area: 'localStorage',
        origin: origin,
      ),
    ],
  );

  group('U19 — manager is a usable CRUD facade', () {
    test('manager_crud', () async {
      final s = sessionFor('a', 'https://a.test');
      await manager.save(s);
      final loaded = await manager.load('a');
      expect(loaded, isNotNull);
      expect(loaded!.id, 'a');
      expect((await manager.list()).length, 1);
      expect(await manager.delete('a'), isTrue);
      expect(await manager.load('a'), isNull);
    });
  });

  group('A1 — persist and restore after restart', () {
    test('persist_and_restore', () async {
      final original = sessionFor('s1', 'https://app.example.com');
      await manager.save(original);
      // Simulated restart: a brand-new store over the same directory.
      final revived = SessionManager(port: FileSessionStore(storeDir));
      final restored = await revived.load('s1');
      expect(restored, isNotNull);
      expect(restored!.toJson(), equals(original.toJson()));
    });
  });

  group('U21 — list surfaces metadata', () {
    test('manager_list_metadata', () async {
      await manager.save(sessionFor('a', 'https://a.test'));
      await manager.save(sessionFor('b', 'https://b.test'));
      final listed = await manager.list();
      expect(listed.map((s) => s.id), unorderedEquals(['a', 'b']));
      final a = listed.firstWhere((s) => s.id == 'a');
      expect(a.name, 'N-a');
      expect(a.origin, 'https://a.test');
      expect(a.updatedAt, 2);
    });
  });

  group('U22 — loading one session does not leak another\'s data', () {
    test('no_cross_leak', () async {
      await manager.save(sessionFor('a', 'https://a.test'));
      await manager.save(sessionFor('b', 'https://b.test'));
      final a = await manager.load('a');
      final b = await manager.load('b');
      expect(a!.storage.first.value, 'v-a');
      expect(b!.storage.first.value, 'v-b');
      expect(a.storage.any((e) => e.value == 'v-b'), isFalse);
      expect(b.storage.any((e) => e.value == 'v-a'), isFalse);
    });
  });
}
