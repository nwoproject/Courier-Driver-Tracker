// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geocoded_waypoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeocodedWaypoint _$GeocodedWaypointFromJson(Map<String, dynamic> json) {
  return GeocodedWaypoint(
    geocoderStatus: json['geocoder_status'] as String,
    placeID: json['place_id'] as String,
    types: (json['types'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$GeocodedWaypointToJson(GeocodedWaypoint instance) =>
    <String, dynamic>{
      'geocoder_status': instance.geocoderStatus,
      'place_id': instance.placeID,
      'types': instance.types,
    };
