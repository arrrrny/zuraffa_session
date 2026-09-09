import '../../domain/entities/portable_session/portable_session.dart';
import '../../domain/entities/portable_session_artifact/portable_session_artifact.dart';
import '../../domain/session/session_port.dart';
import '../../domain/usecases/transport/export_session_usecase.dart';
import '../../domain/usecases/transport/import_session_usecase.dart';
import '../../domain/validation/session_validator.dart';

/// High-level, consumer-facing facade over the session subsystem (spec
/// FR-001 / FR-002 / FR-003 / FR-004 / FR-005 / FR-006 / FR-007 / FR-008).
///
/// Wraps the [SessionPort] (save/load/list/delete) and the transport use cases
/// (export/import) behind one object reachable from a single initialization
/// call. Storage and browser internals are never exposed (SC-004).
class SessionManager {
  final SessionPort _port;
  final SessionValidator _validator;
  final ExportSessionUseCase _exportUseCase;
  final ImportSessionUseCase _importUseCase;

  SessionManager({required SessionPort port, SessionValidator? validator})
    : _port = port,
      _validator = validator ?? SessionValidator(),
      _exportUseCase = ExportSessionUseCase(port),
      _importUseCase = ImportSessionUseCase(
        port,
        validator ?? SessionValidator(),
      );

  /// Persists [session] after validating and normalizing it (spec FR-002 /
  /// FR-003 / FR-012). Throws [SessionValidationException] if the session is
  /// invalid.
  Future<void> save(PortableSession session) async {
    final normalized = _validator.validateAndNormalize(session);
    await _port.save(normalized);
  }

  /// Loads the session saved under [id], or `null` when absent or unreadable
  /// (spec FR-009).
  Future<PortableSession?> load(String id) => _port.load(id);

  /// Lists every readable saved session with id/name/origin/updatedAt (spec
  /// FR-004 / FR-005).
  Future<List<PortableSession>> list() => _port.list();

  /// Deletes the session under [id]; returns whether one was removed (spec
  /// FR-006).
  Future<bool> delete(String id) => _port.delete(id);

  /// Exports the session saved under [id] to a self-contained, relocatable
  /// artifact (spec FR-007).
  Future<PortableSessionArtifact> export(String id) => _exportUseCase(id);

  /// Imports a [PortableSessionArtifact], returning the registered session
  /// (spec FR-008 / FR-010 / FR-011).
  Future<PortableSession> import(PortableSessionArtifact artifact) =>
      _importUseCase(artifact);
}
