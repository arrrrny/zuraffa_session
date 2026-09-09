// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../domain/repositories/portable_session_repository.dart';
import '../../domain/usecases/portable_session/create_portable_session_usecase.dart';

void registerCreatePortableSessionUseCase(GetIt getIt) {
  getIt.registerLazySingleton<CreatePortableSessionUseCase>(
    () => CreatePortableSessionUseCase(getIt<PortableSessionRepository>()),
  );
}

// END GENERATED
