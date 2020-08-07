import 'dart:math';

import 'package:courier_driver_tracker/services/file_handling/json_handler.dart';
import 'package:courier_driver_tracker/services/navigation/delivery_route.dart';
import 'package:geolocator/geolocator.dart';

class NavigatorService{

  DeliveryRoute _deliveryRoutes;
  int _currentDelivery;
  int _currentLeg;
  int _currentStep;
  String jsonFile;


  NavigatorService({this.jsonFile}){
    _currentDelivery = 0;
    _currentStep = 0;
    _currentLeg = 0;
    getRoutes();
  }

  /*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: none
   * Description: Turns json from saved file into DeliveryRoute object.
   *
   */
  getRoutes() async {
    JsonHandler handler = JsonHandler();
    Map<String, dynamic> json = await handler.parseJson(jsonFile);
    _deliveryRoutes = DeliveryRoute.fromJson(json);
  }

  /*
   * Author: Jordan Nijs
   * Parameters: none
   * Returns: none
   * Description: Uses a current position to determine distance away from next point.
   *
   */
  int calculateDistanceBetween(Position currentPosition, Position lastPosition){
    double p = 0.017453292519943295;
    double a = 0.5 - cos((currentPosition.latitude - lastPosition.latitude) * p)/2 +
        cos(lastPosition.latitude * p) * cos(currentPosition.latitude * p) *
            (1 - cos((currentPosition.longitude - lastPosition.longitude) * p))/2;
    return 12742 * asin(sqrt(a)) * 1000 as int;
  }

  updateCurrentPolyline(){} // create new polylines for map to show the route already travveled
  updateDeliveryPolyline(){} // change the previous delivery route polyline colour to show the delivery has been comleted
  getNextDirection(){} // gets the next directions

  /*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: String
   * Description: Gets street names for directions.
   *              \u003c = opening tag and \u003e = closing tags
   */
  String getStreetNames(){
    return _deliveryRoutes.getHTMLInstructions(_currentDelivery, _currentLeg, _currentStep);
  }

  getDirectionIcon(){
    String direction = _deliveryRoutes.getManeuver(_currentDelivery, _currentLeg, _currentStep);
    switch(direction){
      case "turn-right":
        break;
      case "roundabout-right":
        break;
      case "turn-left":
        break;
      case "roundabout-left":
        break;
      default:
        
    }

  } // gets icon to display directions such as right arrow for turn right
  getArrivalTime(){

  } // gets arrival time
  getTotalDistance(){

  }

  int getRemainingDeliveries(){
    return getTotalDeliveries() - _currentDelivery -1;
  }

  int getTotalDeliveries(){
    return _deliveryRoutes.getTotalDeliveries();
  }

  setRouteFilename(String filename){
    jsonFile = filename;
  }

}