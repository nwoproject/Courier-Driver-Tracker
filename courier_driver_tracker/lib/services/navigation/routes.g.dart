// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Routes _$RoutesFromJson(Map<String, dynamic> json) {
  return Routes(
    overviewPolyline: json['overview_polyline'] == null
        ? null
        : OverviewPolyline.fromJson(
            json['overview_polyline'] as Map<String, dynamic>),
    bounds: json['bounds'] == null
        ? null
        : Bounds.fromJson(json['bounds'] as Map<String, dynamic>),
    copyrights: json['copyrights'] as String,
    legs: (json['legs'] as List)
        ?.map(
            (e) => e == null ? null : Legs.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    summary: json['summary'] as String,
    warnings: (json['warnings'] as List)?.map((e) => e as String)?.toList(),
    waypointOrder:
        (json['waypoint_order'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$RoutesToJson(Routes instance) => <String, dynamic>{
      'bounds': instance.bounds?.toJson(),
      'copyrights': instance.copyrights,
      'legs': instance.legs?.map((e) => e?.toJson())?.toList(),
      'overview_polyline': instance.overviewPolyline?.toJson(),
      'summary': instance.summary,
      'warnings': instance.warnings,
      'waypoint_order': instance.waypointOrder,
    };
