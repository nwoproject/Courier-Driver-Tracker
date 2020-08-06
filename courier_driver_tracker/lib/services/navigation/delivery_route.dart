import 'package:courier_driver_tracker/services/navigation/routes.dart';

import 'package:courier_driver_tracker/services/navigation/geocoded_waypoint.dart';
import 'package:json_annotation/json_annotation.dart';

part 'delivery_route.g.dart';

@JsonSerializable(explicitToJson: true)
class DeliveryRoute{
  List<GeocodedWaypoint> geocodedWaypoints;
  List<Routes> routes;
  String status;

  DeliveryRoute({this.geocodedWaypoints, this.routes, this.status});
  factory DeliveryRoute.fromJson(Map<String, dynamic> data) => _$DeliveryRouteFromJson(data);
  Map<String, dynamic> toJson() => _$DeliveryRouteToJson(this);
}