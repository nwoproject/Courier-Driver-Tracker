// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Delivery _$DeliveryFromJson(Map<String, dynamic> json) {
  return Delivery(
    address: json['address'] as String,
    arrivalTime: json['arrivalTime'] as String,
    coordinates: (json['coordinates'] as List)
        ?.map((e) => (e as List)?.map((e) => (e as num)?.toDouble())?.toList())
        ?.toList(),
  );
}
/*
Map<String, dynamic> _$DeliveryToJson(Delivery instance) => <String, dynamic>{
      'coordinates': instance.coordinates,
      'address': instance.address,
      'arrivalTime': instance.arrivalTime,
    };

 */
