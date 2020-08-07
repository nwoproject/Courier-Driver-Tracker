// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'steps.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Steps _$StepsFromJson(Map<String, dynamic> json) {
  return Steps(
    startLocation: json['start_location'] == null
        ? null
        : Location.fromJson(json['start_location'] as Map<String, dynamic>),
    endLocation: json['end_location'] == null
        ? null
        : Location.fromJson(json['end_location'] as Map<String, dynamic>),
    duration: json['duration'] == null
        ? null
        : DriveDuration.fromJson(json['duration'] as Map<String, dynamic>),
    distance: json['distance'] == null
        ? null
        : Distance.fromJson(json['distance'] as Map<String, dynamic>),
    polyline: json['polyline'] == null
        ? null
        : OverviewPolyline.fromJson(json['polyline'] as Map<String, dynamic>),
    htmlInstructions: json['html_instructions'] as String,
    maneuver: json['maneuver'] as String,
  );
}

Map<String, dynamic> _$StepsToJson(Steps instance) => <String, dynamic>{
      'distance': instance.distance?.toJson(),
      'duration': instance.duration?.toJson(),
      'end_location': instance.endLocation?.toJson(),
      'htmlIntructions': instance.htmlInstructions,
      'maneuver': instance.maneuver,
      'polyline': instance.polyline?.toJson(),
      'start_location': instance.startLocation?.toJson()
    };
