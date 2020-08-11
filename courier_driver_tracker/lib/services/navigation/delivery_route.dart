import 'package:courier_driver_tracker/services/navigation/route.dart';
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

  String getHTMLInstruction(int delivery, int leg, int step){
    return routes[delivery].getHTMLInstruction(leg, step);
  }

  String getManeuver(int delivery, int leg, int step){
    return routes[delivery].getManeuver(leg, step);
  }

  int getDuration(int delivery, int leg, int step){
    return routes[delivery].getDuration(leg, step);
  }

  int getDistance(int delivery, int leg, int step){
    return routes[delivery].getDistance(leg, step);
  }

  int getDeliveryDuration(int delivery, int leg){
    return routes[delivery].getDeliveryDuration(leg);
  }

  int getDeliveryDistance(int delivery, int leg){
    return routes[delivery].getDeliveryDistance(leg);
  }
}