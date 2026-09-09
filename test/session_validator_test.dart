import 'package:test/test.dart';
import 'package:zuraffa_session/zuraffa_session.dart';

PortableSession validSession() => PortableSession(
  id: 's1',
  name: 'Valid',
  origin: 'https://x.test',
  createdAt: 1,
  updatedAt: 2,
  cookies: [
    CookieEntry(
      name: 'c',
      value: 'v',
      domain: '.x.test',
      path: '/',
      expiresAt: null,
      secure: true,
      httpOnly: false,
    ),
  ],
  storage: [
    StorageEntry(
      key: 'k',
      value: 'v',
      area: 'localStorage',
      origin: 'https://x.test',
    ),
  ],
);

void main() {
  final validator = SessionValidator();

  group('U6 — accepts a fully valid session', () {
    test('accepts_valid', () {
      expect(validator.validate(validSession()), isEmpty);
    });
  });

  group('U7 — rejects a session with an empty id', () {
    test('rejects_empty_id', () {
      final errors = validator.validate(validSession().copyWith(id: ''));
      expect(errors, isNotEmpty);
      expect(errors.join(' ').toLowerCase(), contains('id'));
    });
  });

  group('U8 — rejects a cookie with an empty name', () {
    test('rejects_empty_cookie_name', () {
      final noName = validSession().copyWith(
        cookies: [
          CookieEntry(
            name: '',
            value: 'v',
            domain: '.x.test',
            path: '/',
            expiresAt: null,
            secure: false,
            httpOnly: false,
          ),
        ],
      );
      expect(
        validator.validate(noName).join(' ').toLowerCase(),
        contains('cookie'),
      );
    });
  });

  group('U8 — rejects a cookie with a missing domain', () {
    test('rejects_missing_cookie_domain', () {
      final noDomain = validSession().copyWith(
        cookies: [
          CookieEntry(
            name: 'c',
            value: 'v',
            domain: '',
            path: '/',
            expiresAt: null,
            secure: false,
            httpOnly: false,
          ),
        ],
      );
      expect(
        validator.validate(noDomain).join(' ').toLowerCase(),
        contains('cookie'),
      );
    });
  });

  group('U9 — defaults an absent cookie path to "/"', () {
    test('normalizes_path', () {
      final absent = validSession().copyWith(
        cookies: [
          CookieEntry(
            name: 'c',
            value: 'v',
            domain: '.x.test',
            path: '',
            expiresAt: null,
            secure: false,
            httpOnly: false,
          ),
        ],
      );
      expect(validator.normalize(absent).cookies.first.path, '/');

      final explicit = validSession().copyWith(
        cookies: [
          CookieEntry(
            name: 'c',
            value: 'v',
            domain: '.x.test',
            path: '/foo',
            expiresAt: null,
            secure: false,
            httpOnly: false,
          ),
        ],
      );
      expect(validator.normalize(explicit).cookies.first.path, '/foo');
    });
  });
}
