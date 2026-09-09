import '../entities/portable_session/portable_session.dart';

/// The technology-agnostic session contract (spec FR-007 / US4).
///
/// Consumers program exclusively against this port — save/load/list/delete
/// a portable session — with no browser or filesystem internals exposed
/// (SC-004). Today it is satisfied by the file-backed session store; when
/// Zuraffa ships its own generic Session interface, this port becomes one
/// adapter of it rather than a rewrite.
abstract class SessionPort {
  /// Persists [session] as a self-contained, relocatable unit.
  ///
  /// Overwrites a previously saved session with the same id. The write is
  /// atomic: a mid-write crash leaves either the previous session or a
  /// temporary file (ignored on load), never a half-written session.
  Future<void> save(PortableSession session);

  /// Loads the session saved under [id], or `null` when absent or
  /// unreadable (corrupt sessions report as not-found, never crash —
  /// FR-009).
  Future<PortableSession?> load(String id);

  /// Lists every readable saved session (FR-005): id, name, origin, and
  /// when it was saved (updatedAt). Corrupt sessions are skipped without
  /// affecting the rest.
  Future<List<PortableSession>> list();

  /// Deletes the session under [id] and frees its persisted data
  /// (FR-011). Returns whether a session was removed.
  Future<bool> delete(String id);
}
