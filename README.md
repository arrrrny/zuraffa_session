# zuraffa_session

Portable browser sessions for the Zuraffa ecosystem — self-contained units of webview state (cookies + DOM storage) that persist to a relocatable store and reload onto a specific site.

Built for consumers like `zikzak_inappwebview` and the `forklift` orchestrator (multiple cloaked browser profiles that must survive restarts), and constructed entirely with the `zfa` clean-architecture CLI: entities, datasources, repositories, and usecases are generated; the hand-written layer is the `SessionPort` contract, the file-backed store, the `SessionManager` facade, the transport codec, the validation layer, and DI wiring.

## Usage

```dart
import 'package:get_it/get_it.dart';
import 'package:zuraffa_session/zuraffa_session.dart';

final getIt = GetIt.instance;
await registerSessionDependencies(
  getIt,
  storeDir: Directory('/path/to/session-store'),
);

final sessions = getIt<SessionPort>();

// Save a session (self-contained: cookies + storage + metadata).
await sessions.save(PortableSession(
  id: 'browser-a',
  name: 'Account A',
  origin: 'https://app.example.com',
  createdAt: DateTime.now().millisecondsSinceEpoch,
  updatedAt: DateTime.now().millisecondsSinceEpoch,
  cookies: [CookieEntry(
    name: 'sid', value: '...', domain: '.example.com',
    path: '/', secure: true, httpOnly: false,
  )],
  storage: [StorageEntry(
    key: 'auth', value: 'token', area: 'localStorage',
    origin: 'https://app.example.com',
  )],
));

// After a restart (or from another consumer sharing the store):
final restored = await sessions.load('browser-a');

// Inventory and cleanup.
final all = await sessions.list();
await sessions.delete('browser-a');
```

### Transportable sessions (export / import)

`SessionManager` wraps the store behind one object and adds a self-contained,
relocatable transport format — a versioned, checksummed
`PortableSessionArtifact` that moves a session across consumers, machines, or
backup media.

```dart
final getIt = GetIt.asNewInstance(); // or GetIt.instance
await registerSessionDependencies(getIt, storeDir: Directory('/path/to/store'));
final manager = getIt<SessionManager>();

await manager.save(session);

// Export to a portable, relocatable artifact.
final artifact = await manager.export(session.id);
final wire = SessionArtifactCodec().encode(artifact); // JSON string

// On another consumer / machine: decode and import.
final received = SessionArtifactCodec().decode(wire);
final imported = await manager.import(received);
// `imported` restores the session; id collisions are resolved to a new id
// so an existing session is never overwritten.
```

The artifact is integrity-verified on import: a tampered checksum or an
unsupported `formatVersion` is rejected (`SessionChecksumException` /
`SessionUnsupportedVersionException`). Saves are validated and normalized
(`SessionValidator`): empty cookie paths default to `/`, storage areas are
canonicalized.

## Design

- **`SessionManager`** — the consumer-facing facade over the store and transport: `save`/`load`/`list`/`delete`, plus `export`/`import` for moving sessions across consumers. Validates and normalizes on save; verifies integrity on import.
- **`SessionPort`** — the general contract (`save`/`load`/`list`/`delete`), independent of browser or filesystem internals. When Zuraffa ships its own generic session interface, this port becomes one adapter of it.
- **`FileSessionStore`** — one JSON file per session under `<storeDir>/sessions/`: self-contained, copyable, relocatable units. Atomic writes (tmp + rename) so a mid-write crash never leaves a half-session; corrupt files are skipped and reported without affecting other sessions.
- **Generated stack** — `PortableSession`/`CookieEntry`/`StorageEntry` entities, the datasource interface, repository, and usecases come from `zfa entity create` / `zfa make` (see `lib/src/`); `PortableSessionFileDataSource` bridges the generated contract onto the store.

## Status

Standalone package under active development (spec `specs/001-portable-browser-sessions`). Depends on `zuraffa` via a path dependency until the next hosted publish (see zuraffa#481/#482).
