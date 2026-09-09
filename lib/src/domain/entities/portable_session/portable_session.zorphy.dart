// dart format width=80
// ignore_for_file: UNNECESSARY_CAST
// ignore_for_file: type=lint

part of 'portable_session.dart';

// **************************************************************************
// ZorphyGenerator
// **************************************************************************

@JsonSerializable(explicitToJson: true, checked: true)
class PortableSession {
  PortableSession({
    required String this.id,
    required String this.name,
    required String this.origin,
    required int this.createdAt,
    required int this.updatedAt,
    required List<CookieEntry> this.cookies,
    required List<StorageEntry> this.storage,
  });

  factory PortableSession.fromJson(Map<String, dynamic> json) =>
      _$PortableSessionFromJson(json);

  final String id;

  final String name;

  final String origin;

  final int createdAt;

  final int updatedAt;

  final List<CookieEntry> cookies;

  final List<StorageEntry> storage;

  PortableSession copyWith({
    String? id,
    String? name,
    String? origin,
    int? createdAt,
    int? updatedAt,
    List<CookieEntry>? cookies,
    List<StorageEntry>? storage,
  }) {
    return PortableSession(
      id: id ?? this.id,
      name: name ?? this.name,
      origin: origin ?? this.origin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cookies: cookies ?? this.cookies,
      storage: storage ?? this.storage,
    );
  }

  PortableSession copyWithPortableSession({
    String? id,
    String? name,
    String? origin,
    int? createdAt,
    int? updatedAt,
    List<CookieEntry>? cookies,
    List<StorageEntry>? storage,
  }) {
    return copyWith(
      id: id,
      name: name,
      origin: origin,
      createdAt: createdAt,
      updatedAt: updatedAt,
      cookies: cookies,
      storage: storage,
    );
  }

  PortableSession patchWithPortableSession([PortableSessionPatch? patchInput]) {
    final _patcher = patchInput ?? PortableSessionPatch();
    final _patchMap = _patcher.patchMap;
    return PortableSession(
      id: _patchMap.containsKey(PortableSession$.id)
          ? ((_patchMap[PortableSession$.id] is Function)
                    ? _patchMap[PortableSession$.id](this.id)
                    : (_patchMap[PortableSession$.id] is Patch)
                    ? _patchMap[PortableSession$.id].applyTo(this.id)
                    : _patchMap[PortableSession$.id])
                as String
          : this.id,
      name: _patchMap.containsKey(PortableSession$.name_)
          ? ((_patchMap[PortableSession$.name_] is Function)
                    ? _patchMap[PortableSession$.name_](this.name)
                    : (_patchMap[PortableSession$.name_] is Patch)
                    ? _patchMap[PortableSession$.name_].applyTo(this.name)
                    : _patchMap[PortableSession$.name_])
                as String
          : this.name,
      origin: _patchMap.containsKey(PortableSession$.origin)
          ? ((_patchMap[PortableSession$.origin] is Function)
                    ? _patchMap[PortableSession$.origin](this.origin)
                    : (_patchMap[PortableSession$.origin] is Patch)
                    ? _patchMap[PortableSession$.origin].applyTo(this.origin)
                    : _patchMap[PortableSession$.origin])
                as String
          : this.origin,
      createdAt: _patchMap.containsKey(PortableSession$.createdAt)
          ? ((_patchMap[PortableSession$.createdAt] is Function)
                    ? _patchMap[PortableSession$.createdAt](this.createdAt)
                    : (_patchMap[PortableSession$.createdAt] is Patch)
                    ? _patchMap[PortableSession$.createdAt].applyTo(
                        this.createdAt,
                      )
                    : _patchMap[PortableSession$.createdAt])
                as int
          : this.createdAt,
      updatedAt: _patchMap.containsKey(PortableSession$.updatedAt)
          ? ((_patchMap[PortableSession$.updatedAt] is Function)
                    ? _patchMap[PortableSession$.updatedAt](this.updatedAt)
                    : (_patchMap[PortableSession$.updatedAt] is Patch)
                    ? _patchMap[PortableSession$.updatedAt].applyTo(
                        this.updatedAt,
                      )
                    : _patchMap[PortableSession$.updatedAt])
                as int
          : this.updatedAt,
      cookies: _patchMap.containsKey(PortableSession$.cookies)
          ? ((_patchMap[PortableSession$.cookies] is Function)
                    ? _patchMap[PortableSession$.cookies](this.cookies)
                    : (_patchMap[PortableSession$.cookies] is Patch)
                    ? _patchMap[PortableSession$.cookies].applyTo(this.cookies)
                    : _patchMap[PortableSession$.cookies])
                as List<CookieEntry>
          : this.cookies,
      storage: _patchMap.containsKey(PortableSession$.storage)
          ? ((_patchMap[PortableSession$.storage] is Function)
                    ? _patchMap[PortableSession$.storage](this.storage)
                    : (_patchMap[PortableSession$.storage] is Patch)
                    ? _patchMap[PortableSession$.storage].applyTo(this.storage)
                    : _patchMap[PortableSession$.storage])
                as List<StorageEntry>
          : this.storage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PortableSession &&
        id == other.id &&
        name == other.name &&
        origin == other.origin &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        cookies == other.cookies &&
        storage == other.storage;
  }

  @override
  int get hashCode {
    return Object.hash(
      this.id,
      this.name,
      this.origin,
      this.createdAt,
      this.updatedAt,
      this.cookies,
      this.storage,
    );
  }

  @override
  String toString() {
    return 'PortableSession(' +
        'id: ${id}' +
        ', ' +
        'name: ${name}' +
        ', ' +
        'origin: ${origin}' +
        ', ' +
        'createdAt: ${createdAt}' +
        ', ' +
        'updatedAt: ${updatedAt}' +
        ', ' +
        'cookies: ${cookies}' +
        ', ' +
        'storage: ${storage})';
  }

  Map<String, dynamic> toJsonLean() {
    final Map<String, dynamic> data = _$PortableSessionToJson(this);
    _sanitizeJson(data);
    return data;
  }

  dynamic _sanitizeJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      json.remove('__typename');
      return json..forEach((key, value) {
        json[key] = _sanitizeJson(value);
      });
    } else if (json is List) {
      return json.map((e) => _sanitizeJson(e)).toList();
    }
    return json;
  }
}

extension PortableSessionPropertyHelpers on PortableSession {
  bool get hasId {
    return this.id.isNotEmpty;
  }

  bool get noId {
    return this.id.isEmpty;
  }

  bool get hasName {
    return this.name.isNotEmpty;
  }

  bool get noName {
    return this.name.isEmpty;
  }

  bool get hasOrigin {
    return this.origin.isNotEmpty;
  }

  bool get noOrigin {
    return this.origin.isEmpty;
  }

  bool get hasCookies {
    return this.cookies.isNotEmpty;
  }

  bool get noCookies {
    return this.cookies.isEmpty;
  }

  bool get hasStorage {
    return this.storage.isNotEmpty;
  }

  bool get noStorage {
    return this.storage.isEmpty;
  }
}

extension PortableSessionSerialization on PortableSession {
  Map<String, dynamic> toJson() {
    return _$PortableSessionToJson(this);
  }
}

enum PortableSession$ {
  id,
  name_,
  origin,
  createdAt,
  updatedAt,
  cookies,
  storage,
}

class PortableSessionPatch
    extends PatchBase<PortableSession, PortableSession$> {
  PortableSession applyTo(PortableSession entity) {
    return entity.patchWithPortableSession(this);
  }

  PortableSessionPatch withId(String? value) {
    patchMap[PortableSession$.id] = value;
    return this;
  }

  PortableSessionPatch withName(String? value) {
    patchMap[PortableSession$.name_] = value;
    return this;
  }

  PortableSessionPatch withOrigin(String? value) {
    patchMap[PortableSession$.origin] = value;
    return this;
  }

  PortableSessionPatch withCreatedAt(int? value) {
    patchMap[PortableSession$.createdAt] = value;
    return this;
  }

  PortableSessionPatch withUpdatedAt(int? value) {
    patchMap[PortableSession$.updatedAt] = value;
    return this;
  }

  PortableSessionPatch withCookies(List<CookieEntry>? value) {
    patchMap[PortableSession$.cookies] = value;
    return this;
  }

  PortableSessionPatch updateCookiesAt(
    int index,
    CookieEntryPatch Function(CookieEntryPatch) patch,
  ) {
    patchMap[PortableSession$.cookies] = (List<dynamic> list) {
      var updatedList = List<CookieEntry>.from(list);
      if (index >= 0 && index < updatedList.length) {
        updatedList[index] = patch(
          CookieEntryPatch(),
        ).applyTo(updatedList[index] as CookieEntry);
      }
      return updatedList;
    };
    return this;
  }

  PortableSessionPatch withStorage(List<StorageEntry>? value) {
    patchMap[PortableSession$.storage] = value;
    return this;
  }

  PortableSessionPatch updateStorageAt(
    int index,
    StorageEntryPatch Function(StorageEntryPatch) patch,
  ) {
    patchMap[PortableSession$.storage] = (List<dynamic> list) {
      var updatedList = List<StorageEntry>.from(list);
      if (index >= 0 && index < updatedList.length) {
        updatedList[index] = patch(
          StorageEntryPatch(),
        ).applyTo(updatedList[index] as StorageEntry);
      }
      return updatedList;
    };
    return this;
  }
}

/// Field descriptors for [PortableSession] query construction
abstract final class PortableSessionFields {
  static const id = Field<PortableSession, String>('id', _$id);

  static const name = Field<PortableSession, String>('name', _$name);

  static const origin = Field<PortableSession, String>('origin', _$origin);

  static const createdAt = Field<PortableSession, int>(
    'createdAt',
    _$createdAt,
  );

  static const updatedAt = Field<PortableSession, int>(
    'updatedAt',
    _$updatedAt,
  );

  static const cookies = Field<PortableSession, List<CookieEntry>>(
    'cookies',
    _$cookies,
  );

  static const storage = Field<PortableSession, List<StorageEntry>>(
    'storage',
    _$storage,
  );

  static String _$id(PortableSession e) {
    return e.id;
  }

  static String _$name(PortableSession e) {
    return e.name;
  }

  static String _$origin(PortableSession e) {
    return e.origin;
  }

  static int _$createdAt(PortableSession e) {
    return e.createdAt;
  }

  static int _$updatedAt(PortableSession e) {
    return e.updatedAt;
  }

  static List<CookieEntry> _$cookies(PortableSession e) {
    return e.cookies;
  }

  static List<StorageEntry> _$storage(PortableSession e) {
    return e.storage;
  }
}

extension PortableSessionCompareE on PortableSession {
  Map<String, dynamic> compareToPortableSession(PortableSession other) {
    final Map<String, dynamic> diff = {};

    if (id != other.id) {
      diff['id'] = () => other.id;
    }

    if (name != other.name) {
      diff['name'] = () => other.name;
    }

    if (origin != other.origin) {
      diff['origin'] = () => other.origin;
    }

    if (createdAt != other.createdAt) {
      diff['createdAt'] = () => other.createdAt;
    }

    if (updatedAt != other.updatedAt) {
      diff['updatedAt'] = () => other.updatedAt;
    }

    if (cookies != other.cookies) {
      diff['cookies'] = () => other.cookies;
    }

    if (storage != other.storage) {
      diff['storage'] = () => other.storage;
    }
    return diff;
  }
}
