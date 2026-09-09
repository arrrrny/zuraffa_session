import '../../../data/transport/session_artifact_codec.dart';
import '../../entities/portable_session/portable_session.dart';
import '../../entities/portable_session_artifact/portable_session_artifact.dart';
import '../../session/session_port.dart';
import '../../validation/session_validator.dart';

/// Imports a [PortableSessionArtifact] into the store (spec FR-008 / FR-010 /
/// FR-011).
///
/// Verifies the artifact's integrity (checksum + supported format version),
/// resolves id collisions non-destructively (a colliding import is registered
/// under a new unique id, preserving the original), validates and normalizes the
/// session, then saves it.
class ImportSessionUseCase {
  final SessionPort _port;
  final SessionValidator _validator;

  ImportSessionUseCase(this._port, this._validator);

  Future<PortableSession> call(PortableSessionArtifact artifact) async {
    // Re-verify integrity even for artifacts built in-memory (not via the codec).
    final codec = const SessionArtifactCodec();
    if (artifact.formatVersion != PortableSessionArtifact.version) {
      throw SessionUnsupportedVersionException(
        'unsupported format version: ${artifact.formatVersion}',
      );
    }
    final expected = codec.computeChecksum(artifact.session);
    if (expected != artifact.checksum) {
      throw const SessionChecksumException(
        'artifact checksum does not match its session',
      );
    }

    // Resolve id collision: never overwrite an existing session.
    var session = artifact.session;
    if (await _port.load(session.id) != null) {
      session = session.copyWith(
        id: '${session.id}__imported',
        name: '${session.name} (imported)',
      );
      var suffix = 1;
      while (await _port.load(session.id) != null) {
        session = session.copyWith(
          id: '${artifact.session.id}__imported_$suffix',
          name: '${artifact.session.name} (imported $suffix)',
        );
        suffix++;
      }
    }

    final normalized = _validator.validateAndNormalize(session);
    await _port.save(normalized);
    return normalized;
  }
}
