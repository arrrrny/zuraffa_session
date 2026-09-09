import 'dart:convert' show jsonDecode, jsonEncode, utf8;

import 'package:crypto/crypto.dart' show sha256;

import '../../domain/entities/portable_session/portable_session.dart';
import '../../domain/entities/portable_session_artifact/portable_session_artifact.dart';

/// Recoverable codec-level error: the artifact's integrity checksum does not
/// match the wrapped session (spec FR-010).
class SessionChecksumException implements Exception {
  final String message;
  const SessionChecksumException(this.message);
  @override
  String toString() => 'SessionChecksumException: $message';
}

/// Recoverable codec-level error: the artifact declares a format version this
/// package cannot read (spec FR-011).
class SessionUnsupportedVersionException implements Exception {
  final String message;
  const SessionUnsupportedVersionException(this.message);
  @override
  String toString() => 'SessionUnsupportedVersionException: $message';
}

/// Encodes/decodes a [PortableSessionArtifact] (spec FR-007 / FR-008 / FR-010 /
/// FR-011).
///
/// Responsibilities:
/// - [encodeSession] wraps a [PortableSession] into an artifact, computing a
///   stable [checksum] over its canonical JSON.
/// - [decode] parses a serialized artifact, rejecting an unsupported
///   `formatVersion` or a mismatched `checksum` so a corrupt/tampered artifact
///   is never silently mis-read.
class SessionArtifactCodec {
  /// Highest version this codec can decode.
  static const int supportedVersion = PortableSessionArtifact.version;

  const SessionArtifactCodec();

  /// Canonical, stable JSON for [session] — same session always yields the same
  /// bytes so the checksum is reproducible.
  String _canonicalJson(PortableSession session) =>
      jsonEncode(session.toJson());

  /// Integrity hash over the canonical session JSON (spec FR-010).
  String computeChecksum(PortableSession session) =>
      sha256.convert(utf8.encode(_canonicalJson(session))).toString();

  /// Wraps [session] into a versioned, checksummed artifact (spec FR-007).
  PortableSessionArtifact encodeSession(
    PortableSession session, {
    int? exportedAt,
  }) => PortableSessionArtifact(
    formatVersion: supportedVersion,
    exportedAt: exportedAt ?? DateTime.now().millisecondsSinceEpoch,
    checksum: computeChecksum(session),
    session: session,
  );

  /// Serializes an artifact to JSON text.
  String encode(PortableSessionArtifact artifact) =>
      jsonEncode(artifact.toJson());

  /// Parses and verifies a serialized artifact.
  ///
  /// Throws [SessionUnsupportedVersionException] when `formatVersion` is not
  /// [supportedVersion], and [SessionChecksumException] when the stored
  /// checksum does not match the wrapped session (spec FR-010 / FR-011).
  PortableSessionArtifact decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const SessionUnsupportedVersionException(
        'artifact is not a JSON object',
      );
    }
    final version = decoded['formatVersion'];
    if (version is! int || version != supportedVersion) {
      throw SessionUnsupportedVersionException(
        'unsupported format version: $version',
      );
    }
    final artifact = PortableSessionArtifact.fromJson(decoded);
    final expected = computeChecksum(artifact.session);
    if (expected != artifact.checksum) {
      throw const SessionChecksumException(
        'artifact checksum does not match its session',
      );
    }
    return artifact;
  }
}
