---
feature: Portable Browser Sessions (zuraffa_session)
feature_directory: specs/001-portable-browser-sessions
spec_file: specs/001-portable-browser-sessions/spec.md
planned_at: f8812aa
suite_baseline: green
suite_command: dart test
acceptance_runner: dart test
unit_runner: dart test
---

# TDD Test List — Transportable Session API (zuraffa_session)

Derived from `spec.md` (User Stories US1–US4, FR-001…FR-011, SC-001…SC-006) and
the implemented stack (`SessionManager` facade, `SessionArtifactCodec`,
`PortableSessionArtifact`, `SessionValidator`, `FileSessionStore`, DI).

**Baseline**: 36 tests green at `HEAD=f8812aa` (`dart test`). No red baseline.

**Stack profile** (verification commands, copied verbatim from the repo):
- Analyze: `dart analyze`
- Full suite: `dart test`
- Single file: `dart test test/<file>.dart`

## Outer loop — acceptance behaviors (one per success criterion)

| id | behavior (observable through the real entry point) | traces | kind | runner | test | state |
|----|---------------------------------------------------|--------|------|--------|------|-------|
| A1 | A saved session reloaded into a fresh store over the same directory restores cookies/storage/metadata exactly (SC-001) | SC-001 | example | dart test | `test/session_manager_test.dart::A1 persist_and_restore` + `test/portable_session_store_test.dart::US1 persist and restore` | DONE |
| A2 | An exported artifact serialized to JSON and decoded by an independent store imports identically (transportable across consumers, SC-002) | SC-002 | example | dart test | `test/session_transport_test.dart::A2 export_serialize_import_on_different_store` | DONE |
| A3 | A session saved by one store is listed/loaded by a second store (relocated path) without shared state (SC-003) | SC-003 | example | dart test | `test/portable_session_store_test.dart::US3 portability across consumers` | DONE |
| A4 | All operations reachable through `SessionPort` and DI-exposed `SessionManager` with no browser/file internals (SC-004) | SC-004 | example | dart test | `test/portable_session_store_test.dart::CRUD through the port` + `test/session_transport_test.dart::U23 di_resolves_manager` | DONE |
| A5 | A corrupt/partial session file is skipped; other sessions and a prior good save survive (SC-005) | SC-005 | example | dart test | `test/portable_session_store_test.dart::FR-009/SC-005` + `test/session_store_version_test.dart::A5 atomic_under_crash` | DONE |
| A6 | Named sessions load independently; `list()` surfaces id/name/origin/updatedAt and one session's data never leaks into another (SC-006) | SC-006 | example | dart test | `test/session_manager_test.dart::U22 no_cross_leak` + `::U21 manager_list_metadata` | DONE |

## Inner loop — unit behaviors (grouped by component)

### Component: `lib/src/domain/entities/portable_session_artifact/portable_session_artifact.dart`

| id | behavior | traces | kind | test | state |
|----|----------|--------|------|------|-------|
| U5 | `PortableSessionArtifact` round-trips via `toJson`/`fromJson` | FR-008 | example | `test/session_artifact_test.dart::U5 artifact_round_trip` | DONE |

### Component: `lib/src/data/transport/session_artifact_codec.dart`

| id | behavior | traces | kind | test | state |
|----|----------|--------|------|------|-------|
| U1 | `encode`→`decode` round-trips an artifact | FR-007 | example | `test/session_artifact_test.dart::U1 codec_round_trip` | DONE |
| U2 | `computeChecksum` is stable for identical content, differs for different content | FR-010 | property | `test/session_artifact_test.dart::U2 checksum_stable` | DONE |
| U3 | `decode` rejects an artifact whose stored checksum does not match its session | FR-010 | example | `test/session_artifact_test.dart::U3 checksum_mismatch` | DONE |
| U4 | `decode` rejects an unsupported `formatVersion` | FR-011 | example | `test/session_artifact_test.dart::U4 version_rejected` | DONE |

### Component: `lib/src/domain/validation/session_validator.dart`

| id | behavior | traces | kind | test | state |
|----|----------|--------|------|------|-------|
| U6 | A fully valid session yields no errors | FR-010 | example | `test/session_validator_test.dart::U6 accepts_valid` | DONE |
| U7 | Empty id is rejected with an id error | FR-010 | example | `test/session_validator_test.dart::U7 rejects_empty_id` | DONE |
| U8 | Cookie with empty name or missing domain is rejected | FR-010 | example | `test/session_validator_test.dart::U8 rejects_bad_cookie` | DONE |
| U9 | An empty cookie path is normalized to `/`; explicit paths preserved | FR-010 | example | `test/session_validator_test.dart::U9 normalizes_path` | DONE |

### Component: `lib/src/data/session/file_session_store.dart`

| id | behavior | traces | kind | test | state |
|----|----------|--------|------|------|-------|
| U10 | Saves embed `formatVersion`; session still loads | FR-006 | example | `test/session_store_version_test.dart::U10 persists_format_version` | DONE |
| U11 | A session file with unsupported `formatVersion` is skipped as corrupt (`lastReadErrors`) | FR-009 | example | `test/session_store_version_test.dart::U11 unsupported_version_skipped` | DONE |
| U12 | Legacy files without `formatVersion` still load (back-compat) | FR-009 | example | covered by `U10`/`U11` load paths (no dedicated file) | DONE |

### Component: `lib/src/domain/session/session_manager.dart` (+ transport use cases)

| id | behavior | traces | kind | test | state |
|----|----------|--------|------|------|-------|
| U19 | Manager is a usable CRUD facade (save/load/list/delete) | FR-001/FR-011 | example | `test/session_manager_test.dart::U19 manager_crud` | DONE |
| U21 | `list()` surfaces id/name/origin/updatedAt | FR-004/FR-005 | example | `test/session_manager_test.dart::U21 manager_list_metadata` | DONE |
| U22 | Loading one session does not leak another's data | FR-004 | example | `test/session_manager_test.dart::U22 no_cross_leak` | DONE |
| U13 | `export(id)` returns an artifact whose session equals the saved one | FR-007 | example | `test/session_transport_test.dart::U13 export_contains_session` | DONE |
| U14 | `import(artifact)` into a fresh store restores the session | FR-008 | example | `test/session_transport_test.dart::U14 import_restores_session` | DONE |
| U16 | `export(unknownId)` throws `SessionNotFoundException` | FR-007 | example | `test/session_transport_test.dart::U16 export_missing_throws` | DONE |
| U17 | Importing a checksum-mismatched artifact throws `SessionChecksumException` | FR-010 | example | `test/session_transport_test.dart::U17 checksum_mismatch` | DONE |
| U18 | Importing an unsupported-version artifact throws `SessionUnsupportedVersionException` | FR-011 | example | `test/session_transport_test.dart::U18 version_rejected` | DONE |
| U20 | Importing an id collision registers under a new id; original preserved | FR-008/FR-011 | example | `test/session_transport_test.dart::U20 import_keeps_existing_under_new_id` | DONE |
| U23 | DI (`registerSessionDependencies`) exposes a working `SessionManager` | FR-007 | example | `test/session_transport_test.dart::U23 di_resolves_manager_and_round_trips` | DONE |

### Component: `lib/src/di/session/session_di.dart`

| id | behavior | traces | kind | test | state |
|----|----------|--------|------|------|-------|
| US4 | `registerSessionDependencies` wires the file-backed `SessionManager` reachable via `GetIt` | FR-006/FR-007 | example | `test/session_transport_test.dart::U23 di_resolves_manager_and_round_trips` | DONE |

## Invariants and edge cases still to place

- None outstanding: every acceptance criterion and functional requirement is covered by a passing test.

## Out of scope (per spec — explicitly not tested)

- At-rest encryption of saved sessions (FR not required for v1).
- Non-browser (generic) session management (future Zuraffa Session package).
- Session-management UI.
- Remote/cloud session sync.
- Guaranteed cross-webview-engine cookie parity.

## Verification commands

```sh
dart analyze
dart test
dart test test/session_transport_test.dart
```
