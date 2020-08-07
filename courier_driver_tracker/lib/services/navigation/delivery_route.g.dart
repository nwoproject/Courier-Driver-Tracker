// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_route.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryRoute _$DeliveryRouteFromJson(Map<String, dynamic> json) {
  return DeliveryRoute(
    routes: (json['routes'] as List)
        ?.map((e) =>
            e == null ? null : Routes.fromJson(e as Map<String, dynamic>))
        ?.toList()
  );
}

Map<String, dynamic> _$DeliveryRouteToJson(DeliveryRoute instance) => <String, dynamic>{
      'routes': instance.routes?.map((e) => e?.toJson())?.toList(),
    };
