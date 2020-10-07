// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bounds.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bounds _$BoundsFromJson(Map<String, dynamic> json) {
  return Bounds(
    southWest: json['southwest'] == null
        ? null
        : LatLng(json['southwest']["lat"], json['southwest']["lng"]),
    northEast: json['northeast'] == null
        ? null
        : LatLng(json['northeast']["lat"], json['northeast']["lng"]),
  );
}

Map<String, dynamic> _$BoundsToJson(Bounds instance) => <String, dynamic>{
      'northeast': instance.northEast?.toJson(),
      'southwest': instance.southWest?.toJson(),
    };
