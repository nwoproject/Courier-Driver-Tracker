import 'package:json_annotation/json_annotation.dart';
part 'geocoded_waypoint.g.dart';

@JsonSerializable()
class GeocodedWaypoint{
  String geocoderStatus;
  String placeID;
  List<String> types;

  GeocodedWaypoint({this.geocoderStatus, this.placeID, this.types});
  factory GeocodedWaypoint.fromJson(Map<String, dynamic> data) => _$GeocodedWaypointFromJson(data);
  Map<String, dynamic> toJson() => _$GeocodedWaypointToJson(this);
}