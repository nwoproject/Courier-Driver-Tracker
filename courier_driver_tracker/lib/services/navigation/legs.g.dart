// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Legs _$LegsFromJson(Map<String, dynamic> json) {
  return Legs(
    distance: json['distance'] == null
        ? null
        : Distance.fromJson(json['distance'] as Map<String, dynamic>),
    steps: (json['steps'] as List)
        ?.map(
            (e) => e == null ? null : Steps.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    duration: json['duration'] == null
        ? null
        : DriveDuration.fromJson(json['duration'] as Map<String, dynamic>),
    endAddress: json['end_address'] as String,
    endLocation: json['end_location'] == null
        ? null
        : Location.fromJson(json['end_location'] as Map<String, dynamic>),
    startAddress: json['start_address'] as String,
    startLocation: json['start_location'] == null
        ? null
        : Location.fromJson(json['start_location'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$LegsToJson(Legs instance) => <String, dynamic>{
      'distance': instance.distance?.toJson(),
      'duration': instance.duration?.toJson(),
      'end_address': instance.endAddress,
      'end_location': instance.endLocation?.toJson(),
      'start_address': instance.startAddress,
      'start_location': instance.startLocation?.toJson(),
      'steps': instance.steps?.map((e) => e?.toJson())?.toList(),
    };
