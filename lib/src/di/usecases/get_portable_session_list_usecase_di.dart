// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../domain/repositories/portable_session_repository.dart';
import '../../domain/usecases/portable_session/get_portable_session_list_usecase.dart';

void registerGetPortableSessionListUseCase(GetIt getIt) {
  getIt.registerLazySingleton<GetPortableSessionListUseCase>(
    () => GetPortableSessionListUseCase(getIt<PortableSessionRepository>()),
  );
}

// END GENERATED
