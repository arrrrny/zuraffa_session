// dart format width=80
// ignore_for_file: UNNECESSARY_CAST
// ignore_for_file: type=lint

part of 'storage_entry.dart';

// **************************************************************************
// ZorphyGenerator
// **************************************************************************

@JsonSerializable(explicitToJson: true, checked: true)
class StorageEntry {
  StorageEntry({
    required String this.key,
    required String this.value,
    required String this.area,
    required String this.origin,
  });

  factory StorageEntry.fromJson(Map<String, dynamic> json) =>
      _$StorageEntryFromJson(json);

  final String key;

  final String value;

  final String area;

  final String origin;

  StorageEntry copyWith({
    String? key,
    String? value,
    String? area,
    String? origin,
  }) {
    return StorageEntry(
      key: key ?? this.key,
      value: value ?? this.value,
      area: area ?? this.area,
      origin: origin ?? this.origin,
    );
  }

  StorageEntry copyWithStorageEntry({
    String? key,
    String? value,
    String? area,
    String? origin,
  }) {
    return copyWith(key: key, value: value, area: area, origin: origin);
  }

  StorageEntry patchWithStorageEntry([StorageEntryPatch? patchInput]) {
    final _patcher = patchInput ?? StorageEntryPatch();
    final _patchMap = _patcher.patchMap;
    return StorageEntry(
      key: _patchMap.containsKey(StorageEntry$.key)
          ? ((_patchMap[StorageEntry$.key] is Function)
                    ? _patchMap[StorageEntry$.key](this.key)
                    : (_patchMap[StorageEntry$.key] is Patch)
                    ? _patchMap[StorageEntry$.key].applyTo(this.key)
                    : _patchMap[StorageEntry$.key])
                as String
          : this.key,
      value: _patchMap.containsKey(StorageEntry$.value)
          ? ((_patchMap[StorageEntry$.value] is Function)
                    ? _patchMap[StorageEntry$.value](this.value)
                    : (_patchMap[StorageEntry$.value] is Patch)
                    ? _patchMap[StorageEntry$.value].applyTo(this.value)
                    : _patchMap[StorageEntry$.value])
                as String
          : this.value,
      area: _patchMap.containsKey(StorageEntry$.area)
          ? ((_patchMap[StorageEntry$.area] is Function)
                    ? _patchMap[StorageEntry$.area](this.area)
                    : (_patchMap[StorageEntry$.area] is Patch)
                    ? _patchMap[StorageEntry$.area].applyTo(this.area)
                    : _patchMap[StorageEntry$.area])
                as String
          : this.area,
      origin: _patchMap.containsKey(StorageEntry$.origin)
          ? ((_patchMap[StorageEntry$.origin] is Function)
                    ? _patchMap[StorageEntry$.origin](this.origin)
                    : (_patchMap[StorageEntry$.origin] is Patch)
                    ? _patchMap[StorageEntry$.origin].applyTo(this.origin)
                    : _patchMap[StorageEntry$.origin])
                as String
          : this.origin,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StorageEntry &&
        key == other.key &&
        value == other.value &&
        area == other.area &&
        origin == other.origin;
  }

  @override
  int get hashCode {
    return Object.hash(this.key, this.value, this.area, this.origin);
  }

  @override
  String toString() {
    return 'StorageEntry(' +
        'key: ${key}' +
        ', ' +
        'value: ${value}' +
        ', ' +
        'area: ${area}' +
        ', ' +
        'origin: ${origin})';
  }

  Map<String, dynamic> toJsonLean() {
    final Map<String, dynamic> data = _$StorageEntryToJson(this);
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

extension StorageEntryPropertyHelpers on StorageEntry {
  bool get hasKey {
    return this.key.isNotEmpty;
  }

  bool get noKey {
    return this.key.isEmpty;
  }

  bool get hasValue {
    return this.value.isNotEmpty;
  }

  bool get noValue {
    return this.value.isEmpty;
  }

  bool get hasArea {
    return this.area.isNotEmpty;
  }

  bool get noArea {
    return this.area.isEmpty;
  }

  bool get hasOrigin {
    return this.origin.isNotEmpty;
  }

  bool get noOrigin {
    return this.origin.isEmpty;
  }
}

extension StorageEntrySerialization on StorageEntry {
  Map<String, dynamic> toJson() {
    return _$StorageEntryToJson(this);
  }
}

enum StorageEntry$ { key, value, area, origin }

class StorageEntryPatch extends PatchBase<StorageEntry, StorageEntry$> {
  StorageEntry applyTo(StorageEntry entity) {
    return entity.patchWithStorageEntry(this);
  }

  StorageEntryPatch withKey(String? value) {
    patchMap[StorageEntry$.key] = value;
    return this;
  }

  StorageEntryPatch withValue(String? value) {
    patchMap[StorageEntry$.value] = value;
    return this;
  }

  StorageEntryPatch withArea(String? value) {
    patchMap[StorageEntry$.area] = value;
    return this;
  }

  StorageEntryPatch withOrigin(String? value) {
    patchMap[StorageEntry$.origin] = value;
    return this;
  }
}

/// Field descriptors for [StorageEntry] query construction
abstract final class StorageEntryFields {
  static const key = Field<StorageEntry, String>('key', _$key);

  static const value = Field<StorageEntry, String>('value', _$value);

  static const area = Field<StorageEntry, String>('area', _$area);

  static const origin = Field<StorageEntry, String>('origin', _$origin);

  static String _$key(StorageEntry e) {
    return e.key;
  }

  static String _$value(StorageEntry e) {
    return e.value;
  }

  static String _$area(StorageEntry e) {
    return e.area;
  }

  static String _$origin(StorageEntry e) {
    return e.origin;
  }
}

extension StorageEntryCompareE on StorageEntry {
  Map<String, dynamic> compareToStorageEntry(StorageEntry other) {
    final Map<String, dynamic> diff = {};

    if (key != other.key) {
      diff['key'] = () => other.key;
    }

    if (value != other.value) {
      diff['value'] = () => other.value;
    }

    if (area != other.area) {
      diff['area'] = () => other.area;
    }

    if (origin != other.origin) {
      diff['origin'] = () => other.origin;
    }
    return diff;
  }
}
