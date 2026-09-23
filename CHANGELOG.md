# Changelog

## 1.2.0 - 2026-09-23

### Breaking

- Widen the `zuraffa` constraint to `^7.0.1` (was `^6.2.2`) so the package
  resolves alongside the zuraffa 7.x ecosystem. Consumers still on zuraffa 6.x
  must upgrade to 7.x before taking this version. `zikzak_inappwebview ^6.0.2`
  and its dependents pick this up through their existing `^1.1.0` constraint.

## 1.1.0

- **Package renamed from `zikzak_session` (0.2.0)** to `zuraffa_session` —
  same portable-session API, new pub.dev identity aligned with the
  Zuraffa fleet (`zuraffa_permissions`, `zuraffa_auth`, …). Consumers
  migrate by swapping the dependency and the import:
  `package:zikzak_session/zikzak_session.dart` →
  `package:zuraffa_session/zuraffa_session.dart`.
- **Built on the published `zuraffa` framework (^6.2.2)** (was ^6.0.0).
- Full Zuraffa package template: homepage/repository/issue_tracker/topics
  metadata, MIT LICENSE.

# Changelog

## 0.2.0 - 2026-08-27

### Features

- Transportable session API: `SessionManager` facade exposing `save` / `load` / `list` / `delete` plus whole-session `export` / `import` (US transportable sessions).
- `ExportSessionUseCase` / `ImportSessionUseCase` move a `PortableSession` across consumers as a self-contained artifact.
- `PortableSessionArtifact` + `SessionArtifactCodec` bundle cookies + DOM storage into a versioned, integrity-checked, transportable artifact (`encode` / `decode`).
- `SessionValidator` consistency checks applied on `save` and `import`.
- DI: `registerSessionDependencies` now also wires the transport use cases behind `SessionManager`.

### Fixes

- Pin `zuraffa` to `^6.0.0` and add `.pubignore` so the package is ready for pub.dev publish.

### Tests

- Harden transport, validator, and store session tests.

### Chores

- Add MIT LICENSE (publish requirement).

## 0.1.0 - 2026-08-24

### Initial publishable release

- `SessionPort` general contract: `save`, `load(id)`, `list()`, `delete(id)` over `PortableSession` — technology-agnostic, no browser internals exposed (FR-1/FR-7, US4).
- `FileSessionStore(Directory)` implements `SessionPort`; sessions are plain JSON files under `<store>/sessions/<id>.json`; atomic save via `.tmp` then rename (FR-2, FR-009).
- Corruption fail-safety per the test contract: corrupt session file is skipped by `list()` (reported in `lastReadErrors`); a `.tmp` leftover is ignored; a file missing `id` is treated as corrupt; `load()` of a corrupt id returns `null`, never throws (FR-3, SC-005).
- Entities: `PortableSession` (id, name, origin, createdAt, updatedAt, cookies, storage + `copyWith`), `CookieEntry` (name, value, domain, path, expiresAt?, secure, httpOnly), `StorageEntry` (key, value, area, origin) — JSON-serializable via generated `.g.dart` (FR-4).
- `registerSessionDependencies(getIt, storeDir:)` wires the real file-backed stack behind `SessionPort` + the zfa-generated repository/usecase surface (FR-5).
- Publishable: hosted `zuraffa: ^6.0.1` (no path dep, no `dependency_overrides`, no `publish_to: 'none'`) (FR-6).

### Known consumers

- `zikzak_inappwebview` — wires `SessionPort` / `FileSessionStore` behind a `WebViewSessionBridge` for portable cookie+storage state (separate PR).
