// dart format width=80
// ignore_for_file: UNNECESSARY_CAST
// ignore_for_file: type=lint

part of 'cookie_entry.dart';

// **************************************************************************
// ZorphyGenerator
// **************************************************************************

@JsonSerializable(explicitToJson: true, checked: true)
class CookieEntry {
  CookieEntry({
    required String this.name,
    required String this.value,
    required String this.domain,
    required String this.path,
    int? this.expiresAt,
    required bool this.secure,
    required bool this.httpOnly,
  });

  factory CookieEntry.fromJson(Map<String, dynamic> json) =>
      _$CookieEntryFromJson(json);

  final String name;

  final String value;

  final String domain;

  final String path;

  final int? expiresAt;

  final bool secure;

  final bool httpOnly;

  CookieEntry copyWith({
    String? name,
    String? value,
    String? domain,
    String? path,
    int? expiresAt,
    bool? secure,
    bool? httpOnly,
  }) {
    return CookieEntry(
      name: name ?? this.name,
      value: value ?? this.value,
      domain: domain ?? this.domain,
      path: path ?? this.path,
      expiresAt: expiresAt ?? this.expiresAt,
      secure: secure ?? this.secure,
      httpOnly: httpOnly ?? this.httpOnly,
    );
  }

  CookieEntry copyWithCookieEntry({
    String? name,
    String? value,
    String? domain,
    String? path,
    int? expiresAt,
    bool? secure,
    bool? httpOnly,
  }) {
    return copyWith(
      name: name,
      value: value,
      domain: domain,
      path: path,
      expiresAt: expiresAt,
      secure: secure,
      httpOnly: httpOnly,
    );
  }

  CookieEntry patchWithCookieEntry([CookieEntryPatch? patchInput]) {
    final _patcher = patchInput ?? CookieEntryPatch();
    final _patchMap = _patcher.patchMap;
    return CookieEntry(
      name: _patchMap.containsKey(CookieEntry$.name_)
          ? ((_patchMap[CookieEntry$.name_] is Function)
                    ? _patchMap[CookieEntry$.name_](this.name)
                    : (_patchMap[CookieEntry$.name_] is Patch)
                    ? _patchMap[CookieEntry$.name_].applyTo(this.name)
                    : _patchMap[CookieEntry$.name_])
                as String
          : this.name,
      value: _patchMap.containsKey(CookieEntry$.value)
          ? ((_patchMap[CookieEntry$.value] is Function)
                    ? _patchMap[CookieEntry$.value](this.value)
                    : (_patchMap[CookieEntry$.value] is Patch)
                    ? _patchMap[CookieEntry$.value].applyTo(this.value)
                    : _patchMap[CookieEntry$.value])
                as String
          : this.value,
      domain: _patchMap.containsKey(CookieEntry$.domain)
          ? ((_patchMap[CookieEntry$.domain] is Function)
                    ? _patchMap[CookieEntry$.domain](this.domain)
                    : (_patchMap[CookieEntry$.domain] is Patch)
                    ? _patchMap[CookieEntry$.domain].applyTo(this.domain)
                    : _patchMap[CookieEntry$.domain])
                as String
          : this.domain,
      path: _patchMap.containsKey(CookieEntry$.path)
          ? ((_patchMap[CookieEntry$.path] is Function)
                    ? _patchMap[CookieEntry$.path](this.path)
                    : (_patchMap[CookieEntry$.path] is Patch)
                    ? _patchMap[CookieEntry$.path].applyTo(this.path)
                    : _patchMap[CookieEntry$.path])
                as String
          : this.path,
      expiresAt: _patchMap.containsKey(CookieEntry$.expiresAt)
          ? ((_patchMap[CookieEntry$.expiresAt] is Function)
                    ? _patchMap[CookieEntry$.expiresAt](this.expiresAt)
                    : (_patchMap[CookieEntry$.expiresAt] is Patch)
                    ? _patchMap[CookieEntry$.expiresAt].applyTo(this.expiresAt)
                    : _patchMap[CookieEntry$.expiresAt])
                as int?
          : this.expiresAt,
      secure: _patchMap.containsKey(CookieEntry$.secure)
          ? ((_patchMap[CookieEntry$.secure] is Function)
                    ? _patchMap[CookieEntry$.secure](this.secure)
                    : (_patchMap[CookieEntry$.secure] is Patch)
                    ? _patchMap[CookieEntry$.secure].applyTo(this.secure)
                    : _patchMap[CookieEntry$.secure])
                as bool
          : this.secure,
      httpOnly: _patchMap.containsKey(CookieEntry$.httpOnly)
          ? ((_patchMap[CookieEntry$.httpOnly] is Function)
                    ? _patchMap[CookieEntry$.httpOnly](this.httpOnly)
                    : (_patchMap[CookieEntry$.httpOnly] is Patch)
                    ? _patchMap[CookieEntry$.httpOnly].applyTo(this.httpOnly)
                    : _patchMap[CookieEntry$.httpOnly])
                as bool
          : this.httpOnly,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CookieEntry &&
        name == other.name &&
        value == other.value &&
        domain == other.domain &&
        path == other.path &&
        expiresAt == other.expiresAt &&
        secure == other.secure &&
        httpOnly == other.httpOnly;
  }

  @override
  int get hashCode {
    return Object.hash(
      this.name,
      this.value,
      this.domain,
      this.path,
      this.expiresAt,
      this.secure,
      this.httpOnly,
    );
  }

  @override
  String toString() {
    return 'CookieEntry(' +
        'name: ${name}' +
        ', ' +
        'value: ${value}' +
        ', ' +
        'domain: ${domain}' +
        ', ' +
        'path: ${path}' +
        ', ' +
        'expiresAt: ${expiresAt}' +
        ', ' +
        'secure: ${secure}' +
        ', ' +
        'httpOnly: ${httpOnly})';
  }

  Map<String, dynamic> toJsonLean() {
    final Map<String, dynamic> data = _$CookieEntryToJson(this);
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

extension CookieEntryPropertyHelpers on CookieEntry {
  bool get hasName {
    return this.name.isNotEmpty;
  }

  bool get noName {
    return this.name.isEmpty;
  }

  bool get hasValue {
    return this.value.isNotEmpty;
  }

  bool get noValue {
    return this.value.isEmpty;
  }

  bool get hasDomain {
    return this.domain.isNotEmpty;
  }

  bool get noDomain {
    return this.domain.isEmpty;
  }

  bool get hasPath {
    return this.path.isNotEmpty;
  }

  bool get noPath {
    return this.path.isEmpty;
  }

  bool get hasExpiresAt {
    return this.expiresAt != null;
  }

  bool get noExpiresAt {
    return this.expiresAt == null;
  }

  int get expiresAtRequired {
    return this.expiresAt ??
        (throw StateError('expiresAt is required but was null'));
  }
}

extension CookieEntrySerialization on CookieEntry {
  Map<String, dynamic> toJson() {
    return _$CookieEntryToJson(this);
  }
}

enum CookieEntry$ { name_, value, domain, path, expiresAt, secure, httpOnly }

class CookieEntryPatch extends PatchBase<CookieEntry, CookieEntry$> {
  CookieEntry applyTo(CookieEntry entity) {
    return entity.patchWithCookieEntry(this);
  }

  CookieEntryPatch withName(String? value) {
    patchMap[CookieEntry$.name_] = value;
    return this;
  }

  CookieEntryPatch withValue(String? value) {
    patchMap[CookieEntry$.value] = value;
    return this;
  }

  CookieEntryPatch withDomain(String? value) {
    patchMap[CookieEntry$.domain] = value;
    return this;
  }

  CookieEntryPatch withPath(String? value) {
    patchMap[CookieEntry$.path] = value;
    return this;
  }

  CookieEntryPatch withExpiresAt(int? value) {
    patchMap[CookieEntry$.expiresAt] = value;
    return this;
  }

  CookieEntryPatch withSecure(bool? value) {
    patchMap[CookieEntry$.secure] = value;
    return this;
  }

  CookieEntryPatch withHttpOnly(bool? value) {
    patchMap[CookieEntry$.httpOnly] = value;
    return this;
  }
}

/// Field descriptors for [CookieEntry] query construction
abstract final class CookieEntryFields {
  static const name = Field<CookieEntry, String>('name', _$name);

  static const value = Field<CookieEntry, String>('value', _$value);

  static const domain = Field<CookieEntry, String>('domain', _$domain);

  static const path = Field<CookieEntry, String>('path', _$path);

  static const expiresAt = Field<CookieEntry, int?>('expiresAt', _$expiresAt);

  static const secure = Field<CookieEntry, bool>('secure', _$secure);

  static const httpOnly = Field<CookieEntry, bool>('httpOnly', _$httpOnly);

  static String _$name(CookieEntry e) {
    return e.name;
  }

  static String _$value(CookieEntry e) {
    return e.value;
  }

  static String _$domain(CookieEntry e) {
    return e.domain;
  }

  static String _$path(CookieEntry e) {
    return e.path;
  }

  static int? _$expiresAt(CookieEntry e) {
    return e.expiresAt;
  }

  static bool _$secure(CookieEntry e) {
    return e.secure;
  }

  static bool _$httpOnly(CookieEntry e) {
    return e.httpOnly;
  }
}

extension CookieEntryCompareE on CookieEntry {
  Map<String, dynamic> compareToCookieEntry(CookieEntry other) {
    final Map<String, dynamic> diff = {};

    if (name != other.name) {
      diff['name'] = () => other.name;
    }

    if (value != other.value) {
      diff['value'] = () => other.value;
    }

    if (domain != other.domain) {
      diff['domain'] = () => other.domain;
    }

    if (path != other.path) {
      diff['path'] = () => other.path;
    }

    if (expiresAt != other.expiresAt) {
      diff['expiresAt'] = () => other.expiresAt;
    }

    if (secure != other.secure) {
      diff['secure'] = () => other.secure;
    }

    if (httpOnly != other.httpOnly) {
      diff['httpOnly'] = () => other.httpOnly;
    }
    return diff;
  }
}
