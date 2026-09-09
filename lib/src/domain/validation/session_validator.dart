import '../entities/portable_session/portable_session.dart';

/// Thrown when a session fails validation (spec FR-010).
class SessionValidationException implements Exception {
  final List<String> errors;
  SessionValidationException(this.errors);

  @override
  String toString() => 'SessionValidationException: ${errors.join('; ')}';
}

/// Validates and normalizes [PortableSession] data for consistency across
/// saves and imports (spec FR-010).
///
/// Validation is non-fatal: [validate] returns a list of messages rather than
/// throwing, so callers can report every problem at once. [validateAndNormalize]
/// throws [SessionValidationException] for convenience when a single hard stop
/// is preferred.
class SessionValidator {
  /// Permitted DOM storage areas (canonical casing).
  static const List<String> validAreas = ['localStorage', 'sessionStorage'];

  /// Default cookie path applied when none is provided.
  static const String defaultCookiePath = '/';

  /// Canonicalizes a storage [area] regardless of casing, or returns `null` if
  /// it is not a known area.
  static String? canonicalArea(String area) {
    final lower = area.trim().toLowerCase();
    for (final candidate in validAreas) {
      if (candidate.toLowerCase() == lower) return candidate;
    }
    return null;
  }

  /// Returns validation errors for [session] (empty list means valid).
  List<String> validate(PortableSession session) {
    final errors = <String>[];
    if (session.id.trim().isEmpty) errors.add('session id must not be empty');
    if (session.name.trim().isEmpty) {
      errors.add('session name must not be empty');
    }
    if (session.origin.trim().isEmpty) {
      errors.add('session origin must not be empty');
    }
    for (final cookie in session.cookies) {
      if (cookie.name.trim().isEmpty) {
        errors.add('cookie name must not be empty');
      }
      if (cookie.domain.trim().isEmpty) {
        errors.add('cookie domain must not be empty');
      }
    }
    for (final entry in session.storage) {
      if (entry.key.trim().isEmpty) {
        errors.add('storage key must not be empty');
      }
      if (canonicalArea(entry.area) == null) {
        errors.add('storage area must be one of ${validAreas.join(', ')}');
      }
      if (entry.origin.trim().isEmpty) {
        errors.add('storage origin must not be empty');
      }
    }
    return errors;
  }

  /// Applies safe defaults without changing valid values: an empty cookie path
  /// becomes [defaultCookiePath]; a valid area's casing is normalized.
  PortableSession normalize(PortableSession session) {
    return session.copyWith(
      cookies: session.cookies.map((cookie) {
        if (cookie.path.trim().isEmpty) {
          return cookie.copyWith(path: defaultCookiePath);
        }
        return cookie;
      }).toList(),
      storage: session.storage.map((entry) {
        final canonical = canonicalArea(entry.area);
        if (canonical != null && canonical != entry.area) {
          return entry.copyWith(area: canonical);
        }
        return entry;
      }).toList(),
    );
  }

  /// Validates [session] and throws [SessionValidationException] if invalid,
  /// otherwise returns the normalized session.
  PortableSession validateAndNormalize(PortableSession session) {
    final errors = validate(session);
    if (errors.isNotEmpty) throw SessionValidationException(errors);
    return normalize(session);
  }
}
