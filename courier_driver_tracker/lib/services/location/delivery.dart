import 'package:json_annotation/json_annotation.dart';

part 'delivery.g.dart';

@JsonSerializable()
class Delivery{
  List<List<double>> coordinates;
  String address;
  String arrivalTime;

  Delivery({this.address, this.arrivalTime, this.coordinates});

  factory Delivery.fromJson(Map<String, dynamic> item) => _$DeliveryFromJson(item);
}