// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deliveries.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************


Deliveries _$DeliveriesFromJson(Map<String, dynamic> json) {
  return Deliveries(
    route: (json['route'] as List)
        ?.map((e) =>
            e == null ? null : Delivery.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$DeliveriesToJson(Deliveries instance) =>
    <String, dynamic>{
      'route': instance.route,
    };
