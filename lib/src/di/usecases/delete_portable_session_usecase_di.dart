// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../domain/repositories/portable_session_repository.dart';
import '../../domain/usecases/portable_session/delete_portable_session_usecase.dart';

void registerDeletePortableSessionUseCase(GetIt getIt) {
  getIt.registerLazySingleton<DeletePortableSessionUseCase>(
    () => DeletePortableSessionUseCase(getIt<PortableSessionRepository>()),
  );
}

// END GENERATED
