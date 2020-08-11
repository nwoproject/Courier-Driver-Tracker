// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leg.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Leg _$LegFromJson(Map<String, dynamic> json) {
  return Leg(
    distance: json['distance'] == null
        ? null
        : json['distance'],
    steps: (json['steps'] as List)
        ?.map(
            (e) => e == null ? null : Step.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    duration: json['duration'] == null
        ? null
        : json['duration'],
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

Map<String, dynamic> _$LegToJson(Leg instance) => <String, dynamic>{
      'distance': instance.distance,
      'duration': instance.duration,
      'end_address': instance.endAddress,
      'end_location': instance.endLocation?.toJson(),
      'start_address': instance.startAddress,
      'start_location': instance.startLocation?.toJson(),
      'steps': instance.steps?.map((e) => e?.toJson())?.toList(),
    };
