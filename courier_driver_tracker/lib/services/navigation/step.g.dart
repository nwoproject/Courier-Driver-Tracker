// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Step _$StepFromJson(Map<String, dynamic> json) {
  return Step(
    startLocation: json['start_location'] == null
        ? null
        : Location.fromJson(json['start_location'] as Map<String, dynamic>),
    endLocation: json['end_location'] == null
        ? null
        : Location.fromJson(json['end_location'] as Map<String, dynamic>),
    duration: json['duration'] == null
        ? null
        : json['duration'],
    distance: json['distance'] == null
        ? null
        : json['distance'],
    polyline: json['polyline'] == null
        ? null
        : OverviewPolyline.fromJson(json['polyline'] as Map<String, dynamic>),
    htmlInstructions: json['html_instructions'] as String,
    maneuver: json['maneuver'] as String,
  );
}

Map<String, dynamic> _$StepToJson(Step instance) => <String, dynamic>{
      'distance': instance.distance,
      'duration': instance.duration,
      'end_location': instance.endLocation?.toJson(),
      'htmlIntructions': instance.htmlInstructions,
      'maneuver': instance.maneuver,
      'polyline': instance.polyline?.toJson(),
      'start_location': instance.startLocation?.toJson()
    };
