# Tasks: zuraffa_session 0.1.0 (publish + consumer wiring)

**Input**: `specs/zuraffa-session-impl/spec.md`

## Phase 0 — Prerequisite (zuraffa 6.0.1 publish)

- [x] T000 Republish zuraffa 6.0.1 with `lib/src/extensions/future_extensions.dart` (PR arrrrny/zuraffa#493 merged + published to pub mirror). Unblocks hosted `zuraffa: ^6.0.1`.

## Phase 1 — Publishability (zuraffa_session)

- [ ] T101 Edit `pubspec.yaml`:
  - Drop `publish_to: 'none'` (FR-6).
  - Bump `version: 0.0.1` → `version: 0.1.0` (FR-6).
  - Replace `zuraffa: { path: ../zuraffa }` block + its comment with `zuraffa: ^6.0.1` (FR-6).
  - Drop `dependency_overrides: { analyzer: 14.1.0 }` (FR-6).
- [ ] T102 `dart pub get` resolves `zuraffa 6.0.1` from the pub mirror (verify `pubspec.lock` shows hosted zuraffa 6.0.1, no path).
- [ ] T103 `dart analyze` — 0 errors, 0 warnings.
- [ ] T104 `dart test` — 11/11 green (US1/US2/US3/FR-009/SC-004 groups unchanged; no test edits).
- [ ] T105 `dart pub publish --dry-run` — no hard errors (warnings about `examples/`/`docs/` dir naming are acceptable; this package has neither).

## Phase 2 — Commit / PR / merge (zuraffa_session)

- [ ] T201 Commit on `feat/zuraffa-session-impl`: `feat: complete zuraffa_session impl (SessionPort/FileSessionStore), publishable 0.1.0`.
- [ ] T202 `git push -u origin feat/zuraffa-session-impl`.
- [ ] T203 `gh pr create --base master --title "feat: implement & publish zuraffa_session 0.1.0" --body "<...>"`.
- [ ] T204 Wait for CI green (or note baseline failures), then `gh pr merge --squash --delete-branch`.
- [ ] T205 `git checkout master && git pull origin master && dart analyze` — confirm post-merge master is clean.

## Phase 3 — Publish 0.1.0 (zuraffa_session)

- [ ] T301 On merged master, `dart pub publish --dry-run` — clean.
- [ ] T302 `dart pub publish --force` — publishes 0.1.0 to the pub mirror.
- [ ] T303 Verify: `curl` the registry's `api/packages/zuraffa_session` → `latest.version == 0.1.0`.

## Phase 4 — Wire consumer (zikzak_inappwebview)

- [ ] T401 `cd /workspace/zikzak_inappwebview && git checkout master && git pull origin master && git checkout -b feat/use-zuraffa-session master`.
- [ ] T402 Add `zuraffa_session: ^0.1.0` to `pubspec.yaml` dependencies.
- [ ] T403 `flutter pub get` resolves zuraffa_session 0.1.0 from the pub mirror.
- [ ] T404 Create `lib/src/webview_sessions/webview_sessions.dart` (barrel) + `webview_session_bridge.dart`:
  - `class WebViewSessionBridge` taking a `SessionPort`.
  - `Future<void> save(String id, InAppWebViewController controller, {required String name, required String origin})` — pull cookies + localStorage/sessionStorage via the webview, build a `PortableSession`, call `port.save`.
  - `Future<void> restore(String id, InAppWebViewController controller)` — `port.load(id)`, write cookies + storage back into the webview.
- [ ] T405 `flutter analyze` — 0 errors, 0 warnings.
- [ ] T406 Commit, push, PR (base master), wait CI, squash-merge.
- [ ] T407 `git checkout master && git pull origin master && flutter analyze` — confirm post-merge master is clean.

## Non-goals (per spec)

- No new tests in zuraffa_session (the existing suite is the contract).
- No remote datasource behavior beyond the zfa-generated scaffold.
- No changes to the zfa CLI.
