// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bounds.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bounds _$BoundsFromJson(Map<String, dynamic> json) {
  return Bounds(
    southWest: json['southwest'] == null
        ? null
        : Location.fromJson(json['southwest'] as Map<String, dynamic>),
    northEast: json['northeast'] == null
        ? null
        : Location.fromJson(json['northeast'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$BoundsToJson(Bounds instance) => <String, dynamic>{
      'northeast': instance.northEast?.toJson(),
      'southwest': instance.southWest?.toJson(),
    };
