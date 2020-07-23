import 'package:courier_driver_tracker/services/location/delivery.dart';
import 'package:json_annotation/json_annotation.dart';

part 'deliveries.g.dart';

@JsonSerializable()
class Deliveries{
  List<Delivery> route;

  Deliveries({this.route});

  factory Deliveries.fromJson(Map<String, dynamic> item) => _$DeliveriesFromJson(item);
}