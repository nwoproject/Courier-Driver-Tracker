// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_route.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryRoute _$DeliveryRouteFromJson(Map<String, dynamic> json) {
  return DeliveryRoute(
    geocodedWaypoints: (json['geocoded_waypoints'] as List)
        ?.map((e) => e == null
            ? null
            : GeocodedWaypoint.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    routes: (json['routes'] as List)
        ?.map((e) =>
            e == null ? null : Routes.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    status: json['status'] as String,
  );
}

Map<String, dynamic> _$DeliveryRouteToJson(DeliveryRoute instance) => <String, dynamic>{
      'geocoded_waypoints':
          instance.geocodedWaypoints?.map((e) => e?.toJson())?.toList(),
      'routes': instance.routes?.map((e) => e?.toJson())?.toList(),
      'status': instance.status,
    };
