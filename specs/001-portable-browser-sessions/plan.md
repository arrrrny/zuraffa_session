# Implementation Plan: Portable Browser Sessions (zuraffa_session standalone)

**Branch**: `001-portable-browser-sessions` | **Date**: 2026-08-23 | **Spec**: [spec.md](../spec.md)

## Summary

Build the standalone `zuraffa_session` package **entirely via the zfa CLI** (hard project rule): `zfa initialize` wires dependencies, `zfa entity create` defines the domain (PortableSession, CookieEntry, StorageEntry), and `zfa make <Entity> ...` generates the clean-architecture stack (datasource/repository/usecase/DI). The **SessionPort** (general save/load/list/delete contract, FR-007/US4) is layered over the generated usecases; the **file-backed SessionStore** implements the datasource contract with atomic writes + corrupt-session fail-safety (FR-009). The zuraffa session plugin (merged today in zuraffa core) is *not* a dependency here — this package must stay standalone with zero runtime deps beyond meta, mirroring the "session data format is platform-agnostic" assumption; its `Session`-shaped API keeps the future adapter path open (US4).

## Technical Context

**Language/Version**: Dart ^3.0.0 (scaffold's SDK constraint; zfa v6.0.0 generates against 3.11 but the output compiles on 3.0+)
**Dependencies**: zero runtime deps (meta only if the generator requires it); dev: test
**Storage**: filesystem store — one JSON file per session under a relocatable directory (FR-006/FR-008: self-contained, copyable units); atomic write via temp-file + rename
**Testing**: `dart test` in-package; corrupt-file simulation by writing garbage bytes
**Constraints**: generation must come from zfa commands (verify each output compiles before continuing — spec's "stop on the first misfire" applies; today's rebuilt zfa has all session/sqlite/format fixes)

## Key Design Decisions

1. **Entity model** (zfa entity create):
   - `PortableSession`: id, name, origin (site), createdAt, updatedAt, cookies (List<CookieEntry>), storage (List<StorageEntry>) — the self-contained unit (FR-001/FR-004).
   - `CookieEntry`: name, value, domain, path, expiresAt?, secure, httpOnly — cookie semantics without a webview dependency.
   - `StorageEntry`: key, value, area (localStorage|sessionStorage), origin — DOM storage restoration data.
2. **SessionPort**: `abstract class SessionPort` with `save/load/list/delete` over `PortableSession` — the only surface consumers see (SC-004). Implemented by `SessionStore` which fronts the generated repository/usecase stack.
3. **Store layout**: `<storeDir>/sessions/<id>.json` (one file per session = self-contained relocatable units, FR-008; concurrent writers can't interleave across sessions, edge case); listing reads metadata only; corrupt file → skip + report, never data loss (FR-009, SC-005).
4. **Atomic save**: write to `<id>.json.tmp` then rename — a mid-write kill leaves either the old session or a `.tmp` (ignored on load), never a half-file.
5. **zfa-driven stack**: `zfa make PortableSession datasource repository usecase di --methods=get,getList,create,update,delete` gives the CRUD machinery; the file store implements the generated datasource interface; DI registers the real datasource behind the repository.

## Project Structure (post-generation)

```text
lib/zuraffa_session.dart          # barrel: entities + SessionPort + SessionStore
lib/src/domain/entities/...      # zfa: portable_session, cookie_entry, storage_entry
lib/src/domain/repositories/...  # zfa: portable_session_repository
lib/src/domain/usecases/...      # zfa: get/get_list/create/update/delete portable_session
lib/src/data/datasources/...     # file store implementing the generated interface
lib/src/di/...                   # zfa: registrations (real datasource wired)
test/                            # port tests: CRUD, portability, corruption, isolation
```

## Complexity Tracking

No constitution violations.
