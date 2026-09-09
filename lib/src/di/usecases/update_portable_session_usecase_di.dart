// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../domain/repositories/portable_session_repository.dart';
import '../../domain/usecases/portable_session/update_portable_session_usecase.dart';

void registerUpdatePortableSessionUseCase(GetIt getIt) {
  getIt.registerLazySingleton<UpdatePortableSessionUseCase>(
    () => UpdatePortableSessionUseCase(getIt<PortableSessionRepository>()),
  );
}

// END GENERATED
