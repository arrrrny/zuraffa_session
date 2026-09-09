import '../../../data/transport/session_artifact_codec.dart';
import '../../entities/portable_session_artifact/portable_session_artifact.dart';
import '../../session/session_port.dart';

/// Thrown when an export is requested for a session id that does not exist.
class SessionNotFoundException implements Exception {
  final String id;
  SessionNotFoundException(this.id);
  @override
  String toString() => 'SessionNotFoundException: no session with id "$id"';
}

/// Exports a stored session into a self-contained, relocatable artifact
/// (spec FR-007).
class ExportSessionUseCase {
  final SessionPort _port;

  ExportSessionUseCase(this._port);

  /// Loads the session under [id] and wraps it in a versioned, checksummed
  /// [PortableSessionArtifact]. Throws [SessionNotFoundException] when the id is
  /// unknown.
  Future<PortableSessionArtifact> call(String id) async {
    final session = await _port.load(id);
    if (session == null) throw SessionNotFoundException(id);
    return const SessionArtifactCodec().encodeSession(session);
  }
}
