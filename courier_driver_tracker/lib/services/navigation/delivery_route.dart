import 'package:courier_driver_tracker/services/navigation/routes.dart';
import 'package:json_annotation/json_annotation.dart';

part 'delivery_route.g.dart';

/*
   * Author: Gian Geyser
   * Description: Overall delivery route containing objects of routes from
   *              delivery to delivery.
   */
@JsonSerializable(explicitToJson: true)
class DeliveryRoute{
  List<Routes> routes;

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