# Implementation Plan: zuraffa_session 0.1.0 (publish + consumer wiring)

**Branch**: `feat/zuraffa-session-impl` | **Date**: 2026-08-24 | **Spec**: [spec.md](./spec.md)

## Summary

The zfa-generated scaffold for `zuraffa_session` already ships a working `SessionPort` + `FileSessionStore` + entities + DI (`dart analyze` clean, `dart test` 11/11 green on master at HEAD). What is *not* done is **publishability** and **consumer integration**. This plan delivers both:

1. **Make the package publishable** — drop `publish_to: 'none'`, bump version `0.0.1 → 0.1.0`, replace the `zuraffa` path dep with a hosted constraint `zuraffa: ^6.0.1` (unblocked today by republishing zuraffa 6.0.1 with the #481 extensions/ packaging fix), and drop the `analyzer: 14.1.0` override that was only there to make the path dep compile.
2. **Wire the consumer** — `zikzak_inappwebview` (currently `NO_CONSUMER_YET`: no `zuraffa_session` import, no `webview_sessions` module) gains `zuraffa_session: ^0.1.0` and a `lib/src/webview_sessions/` module that uses `SessionPort` / `FileSessionStore` to persist and restore webview cookie + DOM storage state as portable sessions.

No test suite weakening: the existing `test/portable_session_store_test.dart` (US1/US2/US3/FR-009/SC-004 groups) stays as-is. The implementation phase is mostly a packaging/pubspec change because the runtime contract is already satisfied; the bulk of the new code lives in the consumer repo.

## Technical Context

**Language/Version**: Dart `^3.11.0` (matches zuraffa 6.0.1's SDK constraint)
**Dependencies** (zuraffa_session):
  - runtime: `json_annotation: ^4.12.0`, `zorphy_annotation: ^2.3.0`, `zuraffa: ^6.0.1` (hosted)
  - dev: `build_runner: ^2.16.0`, `json_serializable: ^6.14.1`, `lints: ^4.0.0`, `mocktail: ^1.0.5`, `test: ^1.24.0`
  - dropped: `dependency_overrides: analyzer: 14.1.0` (only there for the path dep)
**Storage**: filesystem — one JSON file per session under `<storeDir>/sessions/<id>.json` (atomic tmp+rename, corruption-skip)
**Publishing**: target `pub.dev` via the operator-managed pub mirror (token supplied out-of-band). `dart pub publish --dry-run` must produce no hard errors.
**Consumer** (zikzak_inappwebview): Flutter plugin; gains `zuraffa_session: ^0.1.0` hosted dep + a `webview_sessions.dart` module. `flutter analyze` must stay green.

## Key Design Decisions

1. **Versioning**: 0.1.0 (not 1.0.0) — this is the first publishable release; the public API (`SessionPort`, `FileSessionStore`, `registerSessionDependencies`, entity types) is small and stable but pre-1.0 leaves room for breaking changes.
2. **Hosted zuraffa constraint `^6.0.1`** (not `^6.0.0`): 6.0.0 on pub.dev is broken (missing `lib/src/extensions/future_extensions.dart`), so the minimum resolvable, working version is 6.0.1. The `^` allows 6.x patches.
3. **No `dependency_overrides`**: the analyzer pin existed only because the local path checkout of zuraffa needed the same analyzer version as the path-dep workspace. Once hosted, zuraffa's own `dependency_overrides` block (in its published pubspec) handles this — we don't need to mirror it.
4. **Consumer module path**: `lib/src/webview_sessions/webview_sessions.dart` — a single barrel exposing `WebViewSessionBridge` (a thin adapter: `save(sessionId, webView)` / `restore(sessionId, webView)` that pulls cookies + localStorage/sessionStorage out of the webview and into a `PortableSession`, then through `SessionPort.save`). The bridge is webview-engine-agnostic on the *port* side; the engine side is `zikzak_inappwebview`-specific (uses `InAppWebViewController`).
5. **No new tests in zuraffa_session**: the existing suite is the contract; weakening it is forbidden. The plan doesn't add tests because the surface under test isn't changing — only the pubspec.
6. **Consumer tests**: `flutter analyze` is the gate; the bridge is thin enough that adding unit tests would mostly mock the webview controller. The acceptance is `flutter analyze` green with the new dep, mirroring the spec's "After wiring: `flutter analyze` passes with the dep".

## Project Structure (post-implementation)

```text
zuraffa_session/                                  # the publishable package
├── pubspec.yaml                                 # version: 0.1.0, zuraffa: ^6.0.1 hosted
├── lib/
│   ├── zuraffa_session.dart                      # barrel (unchanged)
│   └── src/...                                   # unchanged: entities/store/datasource/di
└── test/portable_session_store_test.dart       # unchanged contract

zikzak_inappwebview/                             # the consumer
├── pubspec.yaml                                 # adds zuraffa_session: ^0.1.0
└── lib/src/webview_sessions/
    ├── webview_sessions.dart                    # barrel: WebViewSessionBridge
    └── webview_session_bridge.dart               # SessionPort ↔ InAppWebViewController adapter
```

## Complexity Tracking

No constitution violations. Single PR per repo (zuraffa_session first, then zikzak_inappwebview). The zuraffa 6.0.1 republish was a prerequisite PR (merged separately — see zuraffa PR #493).
