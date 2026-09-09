// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../../domain/entities/portable_session/portable_session.dart';
import 'portable_session_datasource.dart';

class PortableSessionRemoteDataSource
    with Loggable, FailureHandler
    implements PortableSessionDataSource {
  @override
  Future<PortableSession> get(QueryParams<PortableSession> params) async {
    throw UnimplementedError('Implement remote get');
  }

  @override
  Future<List<PortableSession>> getList(
    ListQueryParams<PortableSession> params,
  ) async {
    throw UnimplementedError('Implement remote getList');
  }

  @override
  Future<PortableSession> create(PortableSession portableSession) async {
    throw UnimplementedError('Implement remote create');
  }

  @override
  Future<PortableSession> update(
    UpdateParams<String, PortableSessionPatch> params,
  ) async {
    throw UnimplementedError('Implement remote update');
  }

  @override
  Future<void> delete(DeleteParams<String> params) async {
    throw UnimplementedError('Implement remote delete');
  }
}

// END GENERATED
