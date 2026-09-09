// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../data/datasources/portable_session/portable_session_remote_datasource.dart';
import '../../data/repositories/data_portable_session_repository.dart';
import '../../domain/repositories/portable_session_repository.dart';

void registerPortableSessionRepository(GetIt getIt) {
  getIt.registerLazySingleton<PortableSessionRepository>(
    () =>
        DataPortableSessionRepository(getIt<PortableSessionRemoteDataSource>()),
  );
}

// END GENERATED
