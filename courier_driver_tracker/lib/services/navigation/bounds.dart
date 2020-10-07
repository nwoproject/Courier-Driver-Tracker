import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bounds.g.dart';

@JsonSerializable(explicitToJson: true)
class Bounds{
  LatLng northEast;
  LatLng southWest;

  Bounds({this.southWest, this.northEast});
  factory Bounds.fromJson(Map<String, dynamic> data) => _$BoundsFromJson(data);
  Map<String, dynamic> toJson() => _$BoundsToJson(this);
}