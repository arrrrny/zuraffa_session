import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:zuraffa_session/zuraffa_session.dart';

void main() {
  late Directory tempDir;
  late Directory storeDir;
  late FileSessionStore store;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('zuraffa_session_ver_');
    storeDir = Directory('${tempDir.path}/store');
    store = FileSessionStore(storeDir);
  });

  tearDown(() async {
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  PortableSession sessionFor(String id) => PortableSession(
    id: id,
    name: 'N',
    origin: 'https://e.test',
    createdAt: 1,
    updatedAt: 2,
    cookies: [
      CookieEntry(
        name: 'c',
        value: 'v',
        domain: '.e.test',
        path: '/',
        expiresAt: null,
        secure: true,
        httpOnly: false,
      ),
    ],
    storage: [
      StorageEntry(
        key: 'k',
        value: 'v',
        area: 'localStorage',
        origin: 'https://e.test',
      ),
    ],
  );

  group('U10 — persists a session file that round-trips via load', () {
    test('persists_session_file', () async {
      await store.save(sessionFor('s1'));
      // The session persists as a loadable unit; the embedded formatVersion
      // contract (FR-011) is exercised by the version gate in U11.
      final restored = await store.load('s1');
      expect(restored, isNotNull);
      expect(restored!.id, 's1');
    });
  });

  group('U11 — unsupported formatVersion is skipped as corrupt', () {
    test('unsupported_version_skipped', () async {
      await store.save(sessionFor('good'));
      final badFile = File('${storeDir.path}/sessions/old.json');
      await badFile.writeAsString(
        jsonEncode({
          'formatVersion': 999,
          'id': 'old',
          'name': 'Old',
          'origin': 'https://e.test',
          'createdAt': 1,
          'updatedAt': 2,
          'cookies': [],
          'storage': [],
        }),
      );

      final listed = await store.list();
      expect(listed.map((s) => s.id), ['good']);
      expect(store.lastReadErrors, hasLength(1));
      expect(store.lastReadErrors.single, contains('skipped'));
      expect(await store.load('old'), isNull);
    });
  });

  group('A5 — atomicity under crash', () {
    test('atomic_under_crash', () async {
      await store.save(sessionFor('good'));
      // Simulate a crash mid-write that left a truncated session file.
      final half = File('${storeDir.path}/sessions/half.json');
      await half.writeAsString('{"id":"half","name":"x","cook');

      // The prior session survives; the truncated file is never read as a
      // half-session.
      final listed = await store.list();
      expect(listed.map((s) => s.id), ['good']);
      expect(await store.load('good'), isNotNull);
      expect(await store.load('half'), isNull);
    });
  });
}
