import 'package:courier_driver_tracker/services/navigation/route.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'delivery_route.g.dart';

/*
   * Author: Gian Geyser
   * Description: Overall delivery route containing objects of routes from
   *              delivery to delivery.
   *
   * Route - The entire route a driver has to follow containing multiple deliveries.
   * Leg - A single route to a delivery containing all the steps(directions).
   * Step - The polyline and directions of how to get to the next step.
   */
@JsonSerializable(explicitToJson: true)
class DeliveryRoute{
  List<Route> routes;

  DeliveryRoute({this.routes});
  factory DeliveryRoute.fromJson(Map<String, dynamic> data) => _$DeliveryRouteFromJson(data);
  Map<String, dynamic> toJson() => _$DeliveryRouteToJson(this);

  int getTotalDeliveries(){
    return routes.length;
  }

  String getHTMLInstruction(int deliveryRoute, int leg, int step){
    return routes[deliveryRoute].getHTMLInstruction(leg, step);
  }

  String getManeuver(int deliveryRoute, int leg, int step){
    return routes[deliveryRoute].getManeuver(leg, step);
  }

  int getStepDuration(int deliveryRoute, int leg, int step){
    return routes[deliveryRoute].getDuration(leg, step);
  }

  int getStepDistance(int deliveryRoute, int leg, int step){
    return routes[deliveryRoute].getDistance(leg, step);
  }

  int getDeliveryDuration(int deliveryRoute, int leg){
    return routes[deliveryRoute].getDeliveryDuration(leg);
  }

  int getDeliveryDistance(int deliveryRoute, int leg){
    return routes[deliveryRoute].getDeliveryDistance(leg);
  }

  String getDeliveryAddress(int deliveryRoute, int leg){
    return routes[deliveryRoute].getDeliveryAddress(leg);
  }

  LatLng getStepStartLatLng(int deliveryRoute, int leg, int step){
    return routes[deliveryRoute].getStepStartLatLng(leg, step);
  }

  LatLng getStepEndLatLng(int deliveryRoute, int leg, int step){
    return routes[deliveryRoute].getStepEndLatLng(leg, step);
  }

  LatLng getNorthEastBound(int deliveryRoute){
    return routes[deliveryRoute].getNorthEastBound();
  }

  LatLng getSouthWestBound(int deliveryRoute){
    return routes[deliveryRoute].getSouthWestBound();
  }
}