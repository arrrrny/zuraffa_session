// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../../domain/entities/portable_session/portable_session.dart';

abstract class PortableSessionDataSource with Loggable, FailureHandler {
  Future<PortableSession> get(QueryParams<PortableSession> params);
  Future<List<PortableSession>> getList(
    ListQueryParams<PortableSession> params,
  );
  Future<PortableSession> create(PortableSession portableSession);
  Future<PortableSession> update(
    UpdateParams<String, PortableSessionPatch> params,
  );
  Future<void> delete(DeleteParams<String> params);
}

// END GENERATED
