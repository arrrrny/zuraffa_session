import 'package:test/test.dart';
import 'package:zuraffa_session/zuraffa_session.dart';

PortableSession sampleSession({String id = 's1', int cookieCount = 2}) =>
    PortableSession(
      id: id,
      name: 'Sample',
      origin: 'https://example.com',
      createdAt: 1000,
      updatedAt: 2000,
      cookies: List.generate(
        cookieCount,
        (i) => CookieEntry(
          name: 'c$i',
          value: 'v$i',
          domain: '.example.com',
          path: '/',
          expiresAt: null,
          secure: true,
          httpOnly: false,
        ),
      ),
      storage: [
        StorageEntry(
          key: 'k',
          value: 'val',
          area: 'localStorage',
          origin: 'https://example.com',
        ),
      ],
    );

void main() {
  final codec = SessionArtifactCodec();

  group('U5 — PortableSessionArtifact round-trips', () {
    test('artifact_round_trip', () {
      final artifact = PortableSessionArtifact(
        formatVersion: PortableSessionArtifact.version,
        exportedAt: 12345,
        checksum: 'abc',
        session: sampleSession(),
      );
      final json = artifact.toJson();
      final restored = PortableSessionArtifact.fromJson(json);
      // Compare via toJson() because the generated PortableSession uses
      // identity-based list equality; toJson() maps deep-compare correctly.
      expect(restored.toJson(), equals(artifact.toJson()));
      expect(restored.session.toJson(), equals(artifact.session.toJson()));
    });
  });

  group('U1 — codec round-trip', () {
    test('codec_round_trip', () {
      final original = sampleSession();
      final artifact = codec.encodeSession(original);
      final decoded = codec.decode(codec.encode(artifact));
      expect(decoded.toJson(), equals(artifact.toJson()));
      expect(decoded.session.toJson(), equals(original.toJson()));
    });
  });

  group('U2 — checksum stability', () {
    test('checksum_stable', () {
      final s1 = sampleSession(id: 'a');
      final s2 = sampleSession(id: 'a');
      final s3 = sampleSession(id: 'a', cookieCount: 3);
      // Same content, different calls and different instances -> identical checksum.
      expect(codec.computeChecksum(s1), codec.computeChecksum(s1));
      expect(codec.computeChecksum(s1), codec.computeChecksum(s2));
      // Different content -> different checksum.
      expect(codec.computeChecksum(s1), isNot(codec.computeChecksum(s3)));
    });
  });

  group('U3 — tampered checksum rejected', () {
    test('checksum_mismatch', () {
      final artifact = codec.encodeSession(sampleSession());
      final tampered = PortableSessionArtifact(
        formatVersion: artifact.formatVersion,
        exportedAt: artifact.exportedAt,
        checksum: artifact.checksum,
        session: artifact.session.copyWith(name: 'Changed'),
      );
      expect(
        () => codec.decode(codec.encode(tampered)),
        throwsA(isA<SessionChecksumException>()),
      );
    });
  });

  group('U4 — unsupported version rejected', () {
    test('version_rejected', () {
      final artifact = codec.encodeSession(sampleSession());
      final bad = PortableSessionArtifact(
        formatVersion: 999,
        exportedAt: artifact.exportedAt,
        checksum: artifact.checksum,
        session: artifact.session,
      );
      expect(
        () => codec.decode(codec.encode(bad)),
        throwsA(isA<SessionUnsupportedVersionException>()),
      );
    });
  });
}
