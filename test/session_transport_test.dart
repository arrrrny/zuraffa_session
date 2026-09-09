import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:test/test.dart';
import 'package:zuraffa_session/zuraffa_session.dart';

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

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'zuraffa_session_transport_',
    );
  });

  tearDown(() async {
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  group('U13 — export yields a self-contained artifact', () {
    test('export_contains_session', () async {
      final storeDir = Directory('${tempDir.path}/store');
      final manager = SessionManager(port: FileSessionStore(storeDir));
      final original = sessionFor('a', 'https://a.test');
      await manager.save(original);

      final artifact = await manager.export('a');
      expect(artifact.formatVersion, PortableSessionArtifact.version);
      expect(artifact.session.toJson(), equals(original.toJson()));
    });
  });

  group('U16 — export of an unknown id fails fast', () {
    test('export_missing_throws', () async {
      final storeDir = Directory('${tempDir.path}/store');
      final manager = SessionManager(port: FileSessionStore(storeDir));
      expect(
        () => manager.export('ghost'),
        throwsA(isA<SessionNotFoundException>()),
      );
    });
  });

  group('U14 — import round-trips the exported session', () {
    test('import_restores_session', () async {
      final storeDir = Directory('${tempDir.path}/store');
      final manager = SessionManager(port: FileSessionStore(storeDir));
      final original = sessionFor('a', 'https://a.test');
      await manager.save(original);

      // Round-trip into a fresh store that does not yet contain id 'a'.
      final artifact = await manager.export('a');
      final targetDir = Directory('${tempDir.path}/target');
      final target = SessionManager(port: FileSessionStore(targetDir));
      final imported = await target.import(artifact);
      expect(imported.toJson(), equals(original.toJson()));
      final reloaded = await target.load(imported.id);
      expect(reloaded!.toJson(), equals(original.toJson()));
    });
  });

  group('A2 — transport across a consumer boundary', () {
    test('export_serialize_import_on_different_store', () async {
      // Consumer 1: produces and exports the artifact.
      final storeA = Directory('${tempDir.path}/a');
      final producer = SessionManager(port: FileSessionStore(storeA));
      final original = sessionFor('s1', 'https://app.example.com');
      await producer.save(original);
      final artifact = await producer.export('s1');
      final wire = const SessionArtifactCodec().encode(artifact);

      // Consumer 2: an independent store that only ever receives the wire bytes.
      final storeB = Directory('${tempDir.path}/b');
      final consumer = SessionManager(port: FileSessionStore(storeB));
      final received = const SessionArtifactCodec().decode(wire);
      final imported = await consumer.import(received);
      final loaded = await consumer.load(imported.id);
      expect(loaded, isNotNull);
      expect(loaded!.toJson(), equals(original.toJson()));
    });
  });

  group('U17 — tampered checksum is rejected on import', () {
    test('checksum_mismatch_throws', () async {
      final storeDir = Directory('${tempDir.path}/store');
      final manager = SessionManager(port: FileSessionStore(storeDir));
      final seed = sessionFor('a', 'https://a.test');
      await manager.save(seed);
      final artifact = await manager.export('a');
      final tampered = PortableSessionArtifact(
        formatVersion: artifact.formatVersion,
        exportedAt: artifact.exportedAt,
        checksum: artifact.checksum,
        session: artifact.session.copyWith(name: 'Changed'),
      );
      expect(
        () => manager.import(tampered),
        throwsA(isA<SessionChecksumException>()),
      );
    });
  });

  group('U18 — unsupported format version is rejected on import', () {
    test('version_rejected_throws', () async {
      final storeDir = Directory('${tempDir.path}/store');
      final manager = SessionManager(port: FileSessionStore(storeDir));
      final seed = sessionFor('a', 'https://a.test');
      await manager.save(seed);
      final artifact = await manager.export('a');
      final bad = PortableSessionArtifact(
        formatVersion: 999,
        exportedAt: artifact.exportedAt,
        checksum: artifact.checksum,
        session: artifact.session,
      );
      expect(
        () => manager.import(bad),
        throwsA(isA<SessionUnsupportedVersionException>()),
      );
    });
  });

  group('U20 — id collision is resolved non-destructively', () {
    test('import_keeps_existing_under_new_id', () async {
      final storeDir = Directory('${tempDir.path}/store');
      final manager = SessionManager(port: FileSessionStore(storeDir));
      final existing = sessionFor('a', 'https://a.test');
      await manager.save(existing);

      // Build an artifact carrying the same id 'a' but different payload.
      final colliding = sessionFor('a', 'https://other.test');
      final artifact = const SessionArtifactCodec().encodeSession(colliding);
      final imported = await manager.import(artifact);

      expect(imported.id, isNot('a'));
      // Original is untouched.
      final reloadedOriginal = await manager.load('a');
      expect(reloadedOriginal!.origin, 'https://a.test');
      final reloadedImport = await manager.load(imported.id);
      expect(reloadedImport!.origin, 'https://other.test');
    });
  });

  group('US4 — manager-level validation on save', () {
    test('save_normalizes_missing_cookie_path', () async {
      final storeDir = Directory('${tempDir.path}/store');
      final manager = SessionManager(port: FileSessionStore(storeDir));
      final session = PortableSession(
        id: 'n1',
        name: 'N1',
        origin: 'https://n.test',
        createdAt: 1,
        updatedAt: 2,
        cookies: [
          CookieEntry(
            name: 'c',
            value: 'v',
            domain: '.n.test',
            path: '', // empty -> normalized to '/'
            expiresAt: null,
            secure: false,
            httpOnly: false,
          ),
        ],
        storage: const [],
      );
      await manager.save(session);
      final loaded = await manager.load('n1');
      expect(loaded!.cookies.first.path, '/');
    });
  });

  group('U23 — DI exposes the manager and use cases', () {
    test('di_resolves_manager_and_round_trips', () async {
      final getIt = GetIt.asNewInstance();
      registerSessionDependencies(
        getIt,
        storeDir: Directory('${tempDir.path}/store'),
      );
      final manager = getIt<SessionManager>();
      final session = sessionFor('d1', 'https://d.test');
      await manager.save(session);
      final loaded = await manager.load('d1');
      expect(loaded!.toJson(), equals(session.toJson()));
    });
  });
}
