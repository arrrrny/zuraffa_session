# Feature Specification: Implement & publish zuraffa_session, consume from zikzak_inappwebview

## Problem
`zuraffa_session` is scaffolded (zfa-generated barrel + entities/usecases/di) but the
runtime implementation is incomplete and the package is not publishable:
- `pubspec.yaml` sets `publish_to: 'none'` and pins `zuraffa` via a PATH dep
  (`path: ../zuraffa`), so `dart pub publish` is blocked (path deps cannot be hosted,
  and `publish_to: 'none'` forbids publishing).
- `lib/src/...` hand-written files are stubs; the contract the existing test expects
  (`FileSessionStore implements SessionPort`, `lastReadErrors`, atomic `.tmp` saves,
  corruption-skip) is not satisfied, so `dart test` fails / code does not compile.
- `zikzak_inappwebview` does NOT yet depend on or use `zuraffa_session` (verified: no
  import, no `webview_sessions` module), so the package is currently unused.

## Goals
- G-1: Complete the real implementation of the session port + file store + entities so
       the EXISTING test suite (`portable_session_store_test.dart`) passes fully.
- G-2: Make the package publishable and publish 0.1.0 to pub.dev (resolve `publish_to`
       and the `zuraffa` path dep; `dart pub publish --dry-run` clean).
- G-3: Make `zikzak_inappwebview` GENUINELY consume `zuraffa_session` (add the dep + a
       `webview_sessions` integration that persists/restores cookie+storage state via
       `SessionPort`/`FileSessionStore`), and pass `flutter analyze`/`build`.

## Requirements
- FR-1: `SessionPort` is the general contract: `save`, `load(id)`, `list()`, `delete(id)`.
- FR-2: `FileSessionStore(Directory)` implements `SessionPort`; sessions are plain JSON
        files under `<store>/sessions/<id>.json`; saves are atomic via a `.tmp` then rename.
- FR-3: Corruption fail-safety (per the test): a corrupt session file is SKIPPED by
        `list()` (reported in `lastReadErrors`), a `.tmp` leftover is ignored, a file
        missing `id` is treated as corrupt, and `load()` of a corrupt id returns `null`
        (never throws).
- FR-4: Entities `PortableSession` (id,name,origin,createdAt,updatedAt,cookies,storage +
        `copyWith`), `CookieEntry` (name,value,domain,path,expiresAt?,secure,httpOnly),
        `StorageEntry` (key,value,area,origin) are JSON-serializable (`.g.dart` present;
        run `dart run build_runner build` if codegen is stale).
- FR-5: `registerSessionDependencies(getIt, storeDir:)` wires the real file-backed stack.
- FR-6: Publishability: remove `publish_to: 'none'`; bump `version:` to `0.1.0`; replace
        the `zuraffa` path dep with a hosted constraint (or coordinate via publish.sh so
        hosted `zuraffa` exists); drop `dependency_overrides` that block publish.
- FR-7: `zikzak_inappwebview/pubspec.yaml` gains `zuraffa_session: ^0.1.0`; a
        `lib/src/webview_sessions/...` module imports `package:zuraffa_session/...` and
        uses `SessionPort`/`FileSessionStore` to save/restore webview session state.

## Non-goals
- No network/remote datasource behavior beyond what the existing `portable_session_*`
  usecases already scaffold (keep them compiling; do not invent a backend).
- No changes to the zfa CLI itself.

## Test plan (acceptance)
- `cd /workspace/zuraffa_session && dart analyze && dart test` — ALL existing tests green
  (US1/US2/US3/FR-009/SC-004 groups). This is the contract; do NOT weaken the tests.
- `dart pub publish --dry-run` clean (no publish blockers).
- After wiring: `cd /workspace/zikzak_inappwebview && flutter analyze` passes with the dep.
