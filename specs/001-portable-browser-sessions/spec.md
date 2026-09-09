# Feature Specification: Portable Browser Sessions (zuraffa_session)

**Feature Branch**: `001-portable-browser-sessions`

**Created**: 2026-08-23

**Status**: Draft

**Input**: User description: "Check our existing package Developer/zikzak_inappwebview that package will be rewritten completely using ONLY zfa cli commands, just like this package, we are creating a zuraffa ecosystem. this session package will be a standalone dart package that will be used by zikzak_inappwebview the goal is simple, portable sessions across plugins. my usecase is that we have the Developer/forklift package which spawns 4 cloaked browsers, the issue with that is that it can not persist sessions on restarts, we will implement a webview based solution using zikzak_inappwebview and have these persistent sessions so we can programmatically load specific sessions on specific sites. while zuraffa itself does not have a session package yet, assume one day it will have and you will also simply use that session interface. that session is not only bounded to be a browser session while this plugin is only portable browser sessions. simple rule ONLY USE clean architecture zuraffa zfa cli commands, no handwritten code. STOP on the first misfire and create a gh issue using /skill:speckit-bug-issue and wait that to be resolved until it is resolved, do not implement any code, since we just switched to zuraffa v6, assume there can be and WILL BE BUGS, not your fault, just stop and report."

## Overview

`zuraffa_session` is a standalone Dart package in the Zuraffa ecosystem that provides **portable browser/webview sessions** — self-contained units of webview state (cookies + DOM storage) that can be saved to disk, relocated, and reloaded into a webview for a specific site. It exists so that consumers such as `zikzak_inappwebview` (and, via it, the `forklift` orchestrator's 4 cloaked browsers) can **persist sessions across app restarts** and **programmatically load a specific named session onto a specific site**.

The package defines its session capabilities behind a **general Session abstraction** that mirrors the future Zuraffa Session interface. Zuraffa does not yet ship a generic session package, but when it does, `zuraffa_session` should become one adapter of it rather than a fork. This package's scope is strictly **browser/webview sessions**; general (non-browser) session concepts remain the responsibility of that future Zuraffa package.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Persist and restore a browser session across app restarts (Priority: P1)

The `forklift` orchestrator spawns multiple cloaked browsers. Today those browsers lose all session state (cookies, login, storage) on restart, forcing re-authentication and breaking automation flows. With this package, after a webview authenticates on a site, its session state is saved; on restart that session is reloaded so the browser resumes exactly where it left off — still logged in, same site state.

**Why this priority**: Directly solves the stated pain point (forklift's 4 cloaked browsers cannot persist sessions on restart). Without this, the package has no reason to exist.

**Independent Test**: Launch a webview, log into a test site, save the session, kill and relaunch the process, load the saved session into a fresh webview pointed at the same site, and verify the user is still authenticated (e.g., a protected page loads without a login prompt).

**Acceptance Scenarios**:

1. **Given** a webview authenticated on site S, **When** the session is saved and the app restarts, **Then** loading that session into a webview at S restores cookies/storage so the user remains authenticated.
2. **Given** no saved sessions exist, **When** the app starts, **Then** it reports zero portable sessions and does not error.

---

### User Story 2 - Programmatically load a specific named session onto a specific site (Priority: P1)

Operators (e.g., forklift) need to pick which saved session goes to which browser/site deterministically. The package exposes the ability to load session "A" into the browser for site X and session "B" into the browser for site Y.

**Why this priority**: The defining property of "portable sessions across plugins" is selective, per-site loading. Pairs with US1 as the core MVP.

**Independent Test**: Save two distinct sessions (different logged-in accounts) for two sites, then load session A into the browser for site X and verify account A's identity; load session B into site Y and verify account B.

**Acceptance Scenarios**:

1. **Given** sessions A and B saved for sites X and Y, **When** load(A, X) and load(B, Y) are requested, **Then** each webview reflects only its assigned session.
2. **Given** a session saved for site X, **When** it is loaded onto a different site Z, **Then** it applies (cookies/storage scoped appropriately) without corrupting other sessions.

---

### User Story 3 - Share sessions across plugins via a common package (Priority: P2)

Because `zuraffa_session` is a standalone package (not bundled inside one plugin), any plugin in the Zuraffa ecosystem — starting with `zikzak_inappwebview` — can read and write the same portable session store. A session saved by one consumer is loadable by another.

**Why this priority**: "Portable sessions across plugins" is the defining property; enables reuse but is not required for the single-plugin MVP.

**Independent Test**: Save a session via one consumer, then from a separate consumer/process that depends on the same package and store location, list and load that session.

**Acceptance Scenarios**:

1. **Given** a session persisted by consumer C1, **When** consumer C2 (separate process, same package + store path) lists sessions, **Then** it sees the session.
2. **Given** the store path is relocated, **When** a consumer is configured with the new path, **Then** it lists/loads sessions from there.

---

### User Story 4 - Conform to a general Session interface for future Zuraffa reuse (Priority: P3)

Zuraffa will eventually ship its own generic Session package (not browser-specific). This package defines its browser-session capabilities behind a Session abstraction that maps onto that future interface, so when it lands, `zuraffa_session` becomes one adapter rather than a rewrite.

**Why this priority**: Future-proofing; not needed for v1 functionality but must shape the core abstraction from day one to avoid a later rewrite.

**Independent Test**: A consumer coding against the general Session port (save/load/list/delete a session) can drive the browser-session implementation without referencing browser internals.

**Acceptance Scenarios**:

1. **Given** the general Session port, **When** the browser-session implementation is registered, **Then** save/load/list/delete operations work through the port only.
2. **Given** a future Zuraffa Session package exists, **Then** `zuraffa_session` can satisfy that interface via an adapter without changing its persistence format.

---

### Edge Cases

- What happens when a saved session is corrupted or partially written (e.g., app killed mid-save)? → Must fail safe: report that session unreadable, leave other sessions intact, never apply half-loaded state.
- What happens when loading a session whose cookies/storage are incompatible with the current webview engine or platform? → Must apply what is valid and report skipped/unsupported items rather than crashing.
- What happens when two consumers write the same session concurrently? → Must serialize writes per session and avoid interleaved corruption.
- What happens when a session is loaded but the target site is unreachable? → Session state is staged; it applies when the webview first navigates, no error.
- What happens when the underlying webview engine version changes between save and load? → Best-effort restore; incompatible persisted items are ignored with a warning.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST persist a webview's current session state (cookies + DOM storage) to a portable, named session on demand.
- **FR-002**: System MUST restore a saved session into a webview instance, re-establishing authentication/state for the target site.
- **FR-003**: System MUST allow a named session to be loaded programmatically against a specific site/URL.
- **FR-004**: System MUST support multiple distinct named sessions (e.g., 4 cloaked browser profiles) coexisting independently.
- **FR-005**: System MUST list all available portable sessions (id, name, associated site, saved-at).
- **FR-006**: System MUST persist sessions to a store location that is accessible across processes/plugins sharing the package.
- **FR-007**: System MUST expose save/load/list/delete through a general Session abstraction independent of browser internals, aligned with the future Zuraffa Session interface.
- **FR-008**: System MUST treat each session as a self-contained, copyable/relocatable unit with no external dependencies.
- **FR-009**: System MUST fail safe on corrupt/partial sessions, preserving other sessions and reporting the problem.
- **FR-010**: System MUST scope its responsibilities to browser/webview sessions only; general (non-browser) session concepts belong to the future Zuraffa Session package.
- **FR-011**: System MUST support deleting a named session and freeing its persisted data.

### Key Entities *(include if feature involves data)*

- **PortableSession (browser session)**: A named, self-contained unit of webview state (cookies + DOM/local storage + metadata: id, name, origin/site, created/updated timestamps). The concrete realization of the general Session port for webviews.
- **SessionStore**: The persistent location (filesystem) where portable sessions live; supports list/save/load/delete and is shared across consumers.
- **SessionPort (general Session interface)**: The technology-agnostic contract (save/load/list/delete a session) that the browser-session implementation satisfies; mirrors the future Zuraffa Session interface.
- **Site/Origin**: The target web origin a session is associated with / loaded onto.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A webview authenticated on a site remains authenticated after app restart when its session is saved and reloaded (measured: protected page loads without login prompt in 100% of test runs).
- **SC-002**: Operators can deterministically load any named session onto any specified site with no cross-contamination between sessions (measured: 4 distinct sessions load correctly onto 4 sites in automated tests).
- **SC-003**: Sessions saved by one consumer are visible and loadable by another consumer using the same package and store (measured: cross-consumer load succeeds in an integration test).
- **SC-004**: 100% of save/load/list/delete operations are reachable through the general Session port without exposing browser internals to the caller.
- **SC-005**: Corrupt or partially-written sessions never cause data loss for other sessions (measured: simulated mid-write kill leaves all other sessions intact and loadable).
- **SC-006**: The package is deliverable as a standalone Dart package consumable by `zikzak_inappwebview` and other Zuraffa ecosystem plugins.

## Assumptions

- Target runtime is the Dart/Flutter Zuraffa ecosystem; the package is consumed by `zikzak_inappwebview` and potentially other plugins.
- Sessions are persisted on the device/local filesystem as portable artifacts (a relocatable store path), not in a remote server.
- A "session" includes cookies and DOM storage (localStorage/sessionStorage) required to restore authentication/state for a site. Exact webview-engine cache semantics are engine-dependent and may be engine-limited.
- The package is built and maintained entirely through the Zuraffa CLI (`zfa`) clean-architecture generators; no hand-written architectural wiring is introduced. This is a hard project rule for this package.
- Zuraffa does not yet ship a generic Session package; this package shapes its abstraction to align with that future interface so it can later become an adapter rather than a fork.
- v1 sessions are stored unencrypted as portable files; at-rest encryption of sensitive auth cookies is deferred (noted as future work) to avoid premature scope.
- The `forklift` use case (4 cloaked browsers) is the primary validation scenario; the initial runtime is the desktop/Linux environment where forklift runs, but the session data format is platform-agnostic.
- Cross-platform (Android/iOS/Windows/macOS/web) webview cookie/store compatibility is best-effort; full parity is out of v1 scope if engine differences prevent it.

## Scope Boundaries

**In scope (v1):**

- Save/load/list/delete portable browser sessions via a general Session port.
- Persistence to a relocatable, cross-consumer store.
- Multiple independent named sessions.
- Fail-safe handling of corrupt/partial sessions.

**Out of scope (v1):**

- At-rest encryption of saved sessions.
- Non-browser (generic) session management — that belongs to the future Zuraffa Session package.
- A UI for managing sessions (consumers drive it programmatically).
- Remote/cloud session sync.
- Guaranteed cross-webview-engine cookie parity.
