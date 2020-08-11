// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Route _$RouteFromJson(Map<String, dynamic> json) {
  return Route(
    overviewPolyline: json['overview_polyline'] == null
        ? null
        : OverviewPolyline.fromJson(
            json['overview_polyline'] as Map<String, dynamic>),
    bounds: json['bounds'] == null
        ? null
        : Bounds.fromJson(json['bounds'] as Map<String, dynamic>),
    legs: (json['legs'] as List)
        ?.map(
            (e) => e == null ? null : Leg.fromJson(e as Map<String, dynamic>))
        ?.toList()
  );
}

Map<String, dynamic> _$RouteToJson(Route instance) => <String, dynamic>{
      'bounds': instance.bounds?.toJson(),
      'legs': instance.legs?.map((e) => e?.toJson())?.toList(),
      'overview_polyline': instance.overviewPolyline?.toJson()
    };
