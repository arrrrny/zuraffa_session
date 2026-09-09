import 'package:zuraffa/zuraffa.dart';

import '../../domain/entities/portable_session/portable_session.dart';
import '../datasources/portable_session/portable_session_datasource.dart';
import 'file_session_store.dart';

/// Bridges the generated [PortableSessionDataSource] contract onto a
/// [FileSessionStore] (spec FR-007 / US4).
///
/// The zfa-generated repository/usecase stack speaks through the generated
/// datasource interface; this adapter translates those calls onto the
/// session port so both surfaces share one store. It also previews the
/// future shape: when Zuraffa ships its generic Session interface, the
/// bridge is exactly this thin.
class PortableSessionFileDataSource
    with Loggable, FailureHandler
    implements PortableSessionDataSource {
  final FileSessionStore store;

  PortableSessionFileDataSource(this.store);

  @override
  Future<PortableSession> get(QueryParams<PortableSession> params) async {
    // In-memory filtering over the store listing, mirroring the mock
    // datasource's query semantics.
    final items = await store.list();
    return items.query(params);
  }

  @override
  Future<List<PortableSession>> getList(
    ListQueryParams<PortableSession> params,
  ) async {
    var items = await store.list();
    if (params.offset != null && params.offset! > 0) {
      items = items.skip(params.offset!).toList();
    }
    if (params.limit != null && params.limit! > 0) {
      items = items.take(params.limit!).toList();
    }
    return items;
  }

  @override
  Future<PortableSession> create(PortableSession portableSession) async {
    await store.save(portableSession);
    return portableSession;
  }

  @override
  Future<PortableSession> update(
    UpdateParams<String, PortableSessionPatch> params,
  ) async {
    final existing = await store.load(params.id);
    if (existing == null) {
      throw notFoundFailure(
        'PortableSession "${params.id}" not found in the session store',
      );
    }
    final updated = params.data.applyTo(existing);
    await store.save(updated);
    return updated;
  }

  @override
  Future<void> delete(DeleteParams<String> params) async {
    await store.delete(params.id);
  }
}
