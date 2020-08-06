// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drive_duration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriveDuration _$DriveDurationFromJson(Map<String, dynamic> json) {
  return DriveDuration(
    value: json['value'] as int,
    text: json['text'] as String,
  );
}

Map<String, dynamic> _$DriveDurationToJson(DriveDuration instance) =>
    <String, dynamic>{
      'text': instance.text,
      'value': instance.value,
    };
