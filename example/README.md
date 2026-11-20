# zuraffa_session

Portable session management for Zuraffa — cookies, storage entries and
import/export of a session as a portable artifact.

## Export and import a session

```dart
import 'package:zuraffa_session/zuraffa_session.dart';

Future<void> main() async {
  final store = FileSessionStore('session.json');
  final manager = SessionManager(store: store);

  await manager.addCookie(CookieEntry(name: 'sid', value: 'abc123'));

  final artifact = await ExportSessionUseCase(manager)();
  await ImportSessionUseCase(manager)(artifact);
}
```

## Validate a session

```dart
import 'package:zuraffa_session/zuraffa_session.dart';

final results = SessionValidator.validate(cookie: myCookie);
```