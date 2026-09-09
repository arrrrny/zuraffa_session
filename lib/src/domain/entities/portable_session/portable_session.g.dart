// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portable_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PortableSession _$PortableSessionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PortableSession', json, ($checkedConvert) {
      final val = PortableSession(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        origin: $checkedConvert('origin', (v) => v as String),
        createdAt: $checkedConvert('createdAt', (v) => (v as num).toInt()),
        updatedAt: $checkedConvert('updatedAt', (v) => (v as num).toInt()),
        cookies: $checkedConvert(
          'cookies',
          (v) => (v as List<dynamic>)
              .map((e) => CookieEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        storage: $checkedConvert(
          'storage',
          (v) => (v as List<dynamic>)
              .map((e) => StorageEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PortableSessionToJson(PortableSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'origin': instance.origin,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'cookies': instance.cookies.map((e) => e.toJson()).toList(),
      'storage': instance.storage.map((e) => e.toJson()).toList(),
    };
