// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cookie_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CookieEntry _$CookieEntryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CookieEntry', json, ($checkedConvert) {
      final val = CookieEntry(
        name: $checkedConvert('name', (v) => v as String),
        value: $checkedConvert('value', (v) => v as String),
        domain: $checkedConvert('domain', (v) => v as String),
        path: $checkedConvert('path', (v) => v as String),
        expiresAt: $checkedConvert('expiresAt', (v) => (v as num?)?.toInt()),
        secure: $checkedConvert('secure', (v) => v as bool),
        httpOnly: $checkedConvert('httpOnly', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$CookieEntryToJson(CookieEntry instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
      'domain': instance.domain,
      'path': instance.path,
      'expiresAt': ?instance.expiresAt,
      'secure': instance.secure,
      'httpOnly': instance.httpOnly,
    };
