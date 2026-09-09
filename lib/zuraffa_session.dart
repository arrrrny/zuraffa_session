/// zuraffa_session — portable browser sessions for the Zuraffa ecosystem.
///
/// A standalone Dart package providing self-contained units of webview
/// state (cookies + DOM storage) that persist to a relocatable store and
/// reload into a webview for a specific site. Built entirely with the zfa
/// clean-architecture CLI: entities, datasources, repositories, and
/// usecases are generated; the [SessionPort] surfaces them through a
/// general session contract (save/load/list/delete) independent of browser
/// internals.
///
/// ```dart
/// final getIt = GetIt.instance;
/// await registerSessionDependencies(getIt, storeDir: dir);
/// final sessions = getIt<SessionPort>();
/// await sessions.save(session);
/// final restored = await sessions.load(session.id);
/// ```
library;

// Domain — the general session contract and generated entities.
export 'src/domain/session/session_port.dart';
export 'src/domain/entities/cookie_entry/cookie_entry.dart';
export 'src/domain/entities/storage_entry/storage_entry.dart';
export 'src/domain/entities/portable_session/portable_session.dart';
export 'src/domain/entities/portable_session_artifact/portable_session_artifact.dart';
export 'src/domain/repositories/portable_session_repository.dart';

// Validation — consistency checks for save/import.
export 'src/domain/validation/session_validator.dart';

// Transport — artifact bundle + codec for moving sessions across consumers.
export 'src/data/transport/session_artifact_codec.dart';

// Facade + transport use cases — the consumer-facing whole-API surface.
export 'src/domain/session/session_manager.dart';
export 'src/domain/usecases/transport/export_session_usecase.dart';
export 'src/domain/usecases/transport/import_session_usecase.dart';

// Data — the file-backed store and its datasource adapter.
export 'src/data/session/file_session_store.dart'
    show FileSessionStore, SessionFileException;
export 'src/data/session/portable_session_file_datasource.dart';

// DI — registers the real (file-backed) stack onto GetIt.
export 'src/di/session/session_di.dart';
