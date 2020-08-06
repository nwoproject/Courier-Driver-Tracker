// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'distance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Distance _$DistanceFromJson(Map<String, dynamic> json) {
  return Distance(
    text: json['text'] as String,
    value: json['value'] as int,
  );
}

Map<String, dynamic> _$DistanceToJson(Distance instance) => <String, dynamic>{
      'text': instance.text,
      'value': instance.value,
    };
