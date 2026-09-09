// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorageEntry _$StorageEntryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('StorageEntry', json, ($checkedConvert) {
      final val = StorageEntry(
        key: $checkedConvert('key', (v) => v as String),
        value: $checkedConvert('value', (v) => v as String),
        area: $checkedConvert('area', (v) => v as String),
        origin: $checkedConvert('origin', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$StorageEntryToJson(StorageEntry instance) =>
    <String, dynamic>{
      'key': instance.key,
      'value': instance.value,
      'area': instance.area,
      'origin': instance.origin,
    };
