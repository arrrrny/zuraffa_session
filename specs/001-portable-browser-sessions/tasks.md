# Tasks: Portable Browser Sessions (zuraffa_session standalone)

**Input**: `specs/001-portable-browser-sessions/spec.md`

## Phase 1 — Package bootstrap (zfa CLI)

- [ ] T001 `zfa initialize --dart --deps-only` in `/workspace/zuraffa_session` (wires zorphy/zuraffa deps into pubspec; verify output compiles: `dart pub get` + `dart analyze` clean).
- [ ] T002 `zfa entity create` × 3: `PortableSession` (id, name, origin, createdAt, updatedAt — collections added via related entities), `CookieEntry` (name, value, domain, path, expiresAt, secure, httpOnly), `StorageEntry` (key, value, area, origin). Then `zfa entity build` to generate .zorphy/.g parts; verify analyze clean.

## Phase 2 — Clean-architecture stack (zfa make)

- [ ] T003 `zfa make PortableSession datasource repository usecase di --methods=get,getList,create,update,delete --id-field id` → verify generated datasource interface + repository + usecases compile.
- [ ] T004 Stop-and-check: run `dart analyze` + the generated tests; any generator misfire → `gh issue create` on arrrrny/zuraffa per the spec's hard rule, then adapt only if the workaround is non-architectural.

## Phase 3 — SessionPort + file store

- [ ] T005 `SessionPort` (save/load/list/delete over PortableSession) in the domain layer — the general contract (FR-007, US4).
- [ ] T006 `FileSessionStore` implementing the generated datasource interface: one JSON file per session under a relocatable dir (FR-006/FR-008), atomic tmp+rename writes (FR-009/SC-005 mid-write-kill), corrupt file → skipped with a reported error (never crashes, never removes others), list returns metadata (id, name, origin, savedAt — FR-005).
- [ ] T007 DI: register the file store behind the generated repository; barrel exports (SessionPort, SessionStore, entities).

## Phase 4 — Tests (US1–US4 + edge cases)

- [ ] T008 CRUD through the port: save → load identical (cookies + storage + metadata), list shows saved, delete frees (FR-011).
- [ ] T009 Portability (US1/US3): save in one store instance, load from a *new* instance at the same path (simulated restart); relocated store path lists/loads the same sessions.
- [ ] T010 Multi-session isolation (US2/SC-002): 4 distinct sessions (the forklift scenario), load(A,X) + load(B,Y) with zero cross-contamination; loading session A onto site Z applies without corrupting others.
- [ ] T011 Corruption safety (FR-009/SC-005): garbage bytes in one session file → that session reported unreadable, all others intact + loadable; a leftover `.tmp` file is ignored.
- [ ] T012 Port-only access (SC-004): all operations exercised through `SessionPort` with no browser/file internals referenced.

## Phase 5 — Ship

- [ ] T013 `dart analyze` clean; `/opt/flutter/bin/dart format`; full `dart test` green.
- [ ] T014 Update lib/zuraffa_session.dart doc comment (real API surface), commit on `feat/001-portable-browser-sessions`, push, PR → merge → pull → re-verify.

## Non-goals (per spec)

- At-rest encryption; remote sync; session management UI; cross-webview-engine cookie parity.

## Phase 6 — Transportable Session API (export/import + facade + validation + DI)

Adds the consumer-facing whole-API surface on top of the file store: a
versioned, checksummed transport bundle, a high-level `SessionManager`,
consistency validation, and DI exposure. Behaviors trace to the TDD test list
(`specs/001-portable-browser-sessions/tdd/test-list.md`).

- [x] T015 `PortableSessionArtifact` — self-contained, checksummed transport bundle (FR-007/FR-008/FR-010/FR-011) [U5]
- [x] T016 `SessionArtifactCodec` — encode/decode with checksum + version verification (FR-007/FR-010/FR-011) [U1][U2][U3][U4]
- [x] T017 `SessionValidator` — validate + normalize (empty-id/cookie/area/path defaults) (FR-010) [U6][U7][U8][U9]
- [x] T018 `FileSessionStore` writes `formatVersion`; skips unsupported versions as corrupt (FR-006/FR-009) [U10][U11][U12]
- [x] T019 `SessionManager` CRUD facade + `export`/`import` transport (FR-001/FR-007/FR-008) [U13][U14][U16][U19][U21][U22]
- [x] T020 `ImportSessionUseCase` rejects tampered/unsupported artifacts; resolves id collisions non-destructively (FR-010/FR-011) [U17][U18][U20]
- [x] T021 `registerSessionDependencies` exposes `SessionManager` via `GetIt` (FR-006/FR-007) [U23][US4]
- [x] T022 Acceptance gate green: A1–A6 (SC-001…SC-006) via `dart test` (36 tests) — baseline `green` at `f8812aa`.
- [x] T023 `dart analyze` clean (one accepted warning: `../zuraffa` path dep; hosted 6.0.0 broken) + `/opt/flutter/bin/dart format` applied.

