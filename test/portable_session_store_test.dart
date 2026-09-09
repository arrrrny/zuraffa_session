import 'dart:io';

import 'package:test/test.dart';
import 'package:zuraffa_session/zuraffa_session.dart';

/// Spec `001-portable-browser-sessions` — the port surface (SC-004) drives
/// everything: CRUD, restart portability (US1), named-session isolation
/// (US2), cross-consumer/cross-path portability (US3), and corruption
/// fail-safety (FR-009/SC-005).
void main() {
  late Directory tempDir;
  late Directory storeDir;
  late FileSessionStore store;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('zuraffa_session_');
    storeDir = Directory('${tempDir.path}/store');
    store = FileSessionStore(storeDir);
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  PortableSession sessionFor(
    String id,
    String name,
    String origin, {
    int cookieCount = 1,
  }) => PortableSession(
    id: id,
    name: name,
    origin: origin,
    createdAt: 1000,
    updatedAt: 2000,
    cookies: List.generate(
      cookieCount,
      (i) => CookieEntry(
        name: 'cookie-$i',
        value: 'value-$i-$id',
        domain: origin,
        path: '/',
        expiresAt: null,
        secure: true,
        httpOnly: false,
      ),
    ),
    storage: [
      StorageEntry(
        key: 'auth',
        value: 'token-$id',
        area: 'localStorage',
        origin: origin,
      ),
      StorageEntry(
        key: 'draft',
        value: 'note-$id',
        area: 'sessionStorage',
        origin: origin,
      ),
    ],
  );

  group('US1 — persist and restore across restarts', () {
    test(
      'save → fresh store instance (restart) → load restores exactly',
      () async {
        final session = sessionFor(
          's1',
          'Primary',
          'https://app.example.com',
          cookieCount: 3,
        );
        await store.save(session);

        // Simulated restart: a brand-new store over the same directory.
        final revived = FileSessionStore(storeDir);
        final restored = await revived.load('s1');

        expect(restored, isNotNull);
        expect(restored!.id, 's1');
        expect(restored.name, 'Primary');
        expect(restored.origin, 'https://app.example.com');
        expect(restored.cookies, hasLength(3));
        expect(restored.cookies.first.name, 'cookie-0');
        expect(restored.cookies.first.secure, isTrue);
        expect(restored.storage, hasLength(2));
        expect(
          restored.storage
              .firstWhere((entry) => entry.area == 'localStorage')
              .value,
          'token-s1',
        );
      },
    );

    test('an empty store reports zero sessions without error', () async {
      expect(await store.list(), isEmpty);
      expect(await store.load('missing'), isNull);
      expect(await store.delete('missing'), isFalse);
    });
  });

  group('US2 — named sessions load onto specific sites', () {
    test(
      'four distinct sessions coexist and load independently (forklift)',
      () async {
        final sessions = [
          sessionFor('browser-a', 'Account A', 'https://alpha.test'),
          sessionFor('browser-b', 'Account B', 'https://beta.test'),
          sessionFor('browser-c', 'Account C', 'https://gamma.test'),
          sessionFor('browser-d', 'Account D', 'https://delta.test'),
        ];
        for (final session in sessions) {
          await store.save(session);
        }

        final listed = await store.list();
        expect(listed, hasLength(4));

        final a = await store.load('browser-a');
        final d = await store.load('browser-d');
        expect(a!.origin, 'https://alpha.test');
        expect(a.storage.first.value, 'token-browser-a');
        expect(d!.origin, 'https://delta.test');
        expect(d.storage.first.value, 'token-browser-d');
        expect(a.cookies.first.value, 'value-0-browser-a');
        expect(d.cookies.first.value, 'value-0-browser-d');
      },
    );

    test('loading a session onto a different site applies without '
        'corrupting others', () async {
      final x = sessionFor('for-x', 'X profile', 'https://x.test');
      await store.save(x);
      await store.save(sessionFor('for-y', 'Y profile', 'https://y.test'));

      // Re-key the same session data at another id/site (the "load onto
      // site Z" flow: the session unit itself is self-contained).
      final reloaded = x.copyWith(id: 'for-z', origin: 'https://z.test');
      await store.save(reloaded);

      expect((await store.load('for-z'))!.origin, 'https://z.test');
      expect((await store.load('for-x'))!.origin, 'https://x.test');
      expect((await store.load('for-y'))!.origin, 'https://y.test');
      expect(await store.list(), hasLength(3));
    });
  });

  group('US3 — portability across consumers and paths', () {
    test('a second consumer (new process model) sees saved sessions', () async {
      await store.save(sessionFor('shared', 'Shared', 'https://shared.test'));

      // A separate consumer = another store instance at the same path.
      final consumer2 = FileSessionStore(storeDir);
      final listed = await consumer2.list();
      expect(listed, hasLength(1));
      expect(listed.first.id, 'shared');
      expect(await consumer2.load('shared'), isNotNull);
    });

    test('a relocated store path lists and loads the same sessions', () async {
      await store.save(sessionFor('moved', 'Movable', 'https://move.test'));

      // Relocate the whole directory; the sessions are plain files.
      final relocated = Directory('${tempDir.path}/relocated');
      await storeDir.rename(relocated.path);

      final storeAtNewPath = FileSessionStore(relocated);
      final listed = await storeAtNewPath.list();
      expect(listed, hasLength(1));
      expect(listed.first.name, 'Movable');
    });
  });

  group('FR-009/SC-005 — corruption fail-safety', () {
    test('a corrupt session file is skipped; others stay intact', () async {
      await store.save(sessionFor('good-1', 'Good 1', 'https://one.test'));
      await store.save(sessionFor('bad', 'Bad', 'https://bad.test'));
      await store.save(sessionFor('good-2', 'Good 2', 'https://two.test'));

      // Simulate a mid-write kill: garbage bytes in one session file.
      final badFile = File('${storeDir.path}/sessions/bad.json');
      await badFile.writeAsString('{ this is not valid json !!');

      final listed = await store.list();
      expect(
        listed.map((s) => s.id),
        unorderedEquals(['good-1', 'good-2']),
        reason: 'corrupt session is skipped',
      );
      expect(store.lastReadErrors, hasLength(1));
      expect(store.lastReadErrors.single, contains('bad'));

      expect(await store.load('good-1'), isNotNull);
      expect(await store.load('good-2'), isNotNull);
      expect(
        await store.load('bad'),
        isNull,
        reason: 'direct load of a corrupt session is not-found, no throw',
      );
    });

    test(
      'a half-written temp file from an interrupted save is ignored',
      () async {
        await store.save(sessionFor('done', 'Done', 'https://done.test'));
        // The atomic-save leftover: a .tmp file that never got renamed.
        await File(
          '${storeDir.path}/sessions/pending.json.tmp',
        ).writeAsString('{"id":"pending","nam');

        final listed = await store.list();
        expect(listed.map((s) => s.id), ['done']);
        expect(
          store.lastReadErrors,
          isEmpty,
          reason: 'tmp files are ignored, not reported as corruption',
        );
      },
    );

    test('a session file missing its id is treated as corrupt', () async {
      await store.save(sessionFor('ok', 'OK', 'https://ok.test'));
      await File(
        '${storeDir.path}/sessions/no-id.json',
      ).writeAsString('{"name":"idless"}');

      final listed = await store.list();
      expect(listed.map((s) => s.id), ['ok']);
      expect(store.lastReadErrors, hasLength(1));
    });
  });

  group('CRUD through the port (SC-004)', () {
    test('save/load/list/delete with no file internals in the test', () async {
      SessionPort port = store;

      await port.save(sessionFor('p1', 'Port One', 'https://port.test'));
      await port.save(sessionFor('p2', 'Port Two', 'https://port2.test'));

      final loaded = await port.load('p1');
      expect(loaded!.name, 'Port One');
      expect((await port.list()).length, 2);

      expect(await port.delete('p1'), isTrue);
      expect(await port.load('p1'), isNull);
      expect((await port.list()).length, 1);
      expect(await port.delete('p1'), isFalse, reason: 'already deleted');
    });

    test('overwriting a session keeps a single copy', () async {
      await store.save(sessionFor('dup', 'First', 'https://dup.test'));
      await store.save(sessionFor('dup', 'Second', 'https://dup2.test'));

      expect(await store.list(), hasLength(1));
      expect((await store.load('dup'))!.name, 'Second');
    });
  });
}
