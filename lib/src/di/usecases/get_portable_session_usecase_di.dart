// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../domain/repositories/portable_session_repository.dart';
import '../../domain/usecases/portable_session/get_portable_session_usecase.dart';

void registerGetPortableSessionUseCase(GetIt getIt) {
  getIt.registerLazySingleton<GetPortableSessionUseCase>(
    () => GetPortableSessionUseCase(getIt<PortableSessionRepository>()),
  );
}

// END GENERATED
