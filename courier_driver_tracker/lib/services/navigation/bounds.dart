import 'package:courier_driver_tracker/services/navigation/location.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bounds.g.dart';

@JsonSerializable(explicitToJson: true)
class Bounds{
  Location northEast;
  Location southWest;

  Bounds({this.southWest, this.northEast});
  factory Bounds.fromJson(Map<String, dynamic> data) => _$BoundsFromJson(data);
  Map<String, dynamic> toJson() => _$BoundsToJson(this);
}