import 'dart:io';

import 'package:zuraffa/zuraffa.dart';

import '../../data/session/portable_session_file_datasource.dart';
import '../../data/repositories/data_portable_session_repository.dart';
import '../../domain/repositories/portable_session_repository.dart';
import '../../domain/session/session_port.dart';
import '../../domain/session/session_manager.dart';
import '../../data/session/file_session_store.dart';
import '../usecases/index.dart' as usecases;

/// Registers the real session stack onto [getIt] (spec FR-006/FR-007).
///
/// The zfa-generated `setupDependencies` wires the scaffold remote
/// datasource (a stub that throws); applications building on the portable
/// session store call this instead — same usecase registrations, but the
/// repository is backed by the [FileSessionStore] behind the
/// [SessionPort], so both the port surface and the generated
/// repository/usecase surface share one store:
///
/// ```dart
/// final getIt = GetIt.instance;
/// await registerSessionDependencies(
///   getIt,
///   storeDir: Directory('/path/to/sessions'),
/// );
/// final sessions = getIt<SessionPort>();
/// ```
///
/// The store directory is relocatable: point another consumer at the same
/// path and it sees the same sessions (US3).
void registerSessionDependencies(GetIt getIt, {required Directory storeDir}) {
  getIt
    ..registerLazySingleton<FileSessionStore>(() => FileSessionStore(storeDir))
    ..registerLazySingleton<SessionPort>(() => getIt<FileSessionStore>())
    ..registerLazySingleton<PortableSessionFileDataSource>(
      () => PortableSessionFileDataSource(getIt<FileSessionStore>()),
    )
    ..registerLazySingleton<PortableSessionRepository>(
      () =>
          DataPortableSessionRepository(getIt<PortableSessionFileDataSource>()),
    )
    ..registerLazySingleton<SessionManager>(
      () => SessionManager(port: getIt<SessionPort>()),
    );
  // The generated usecase registrations resolve the repository above.
  usecases.registerAllUseCases(getIt);
}
