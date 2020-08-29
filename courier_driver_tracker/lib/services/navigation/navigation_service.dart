import 'dart:math';
import 'package:courier_driver_tracker/services/abnormality/abnormality_service.dart';
import 'package:courier_driver_tracker/services/file_handling/json_handler.dart';
import 'package:courier_driver_tracker/services/navigation/delivery_route.dart';
import 'package:courier_driver_tracker/services/notification/local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NavigationService {
  /*
   * Author: Gian Geyser
   * Description: Navigation class.
   */

  DeliveryRoute _deliveryRoutes;
  int _currentRoute;
  int _currentLeg; // delivery
  int _currentStep; // directions
  int _stepEndPoint;
  String jsonFile;
  LocalNotifications _notificationManager = LocalNotifications();
  AbnormalityService _abnormalityService = AbnormalityService();
  Position _position;
  bool _doneWithDelivery;

  // Map polylines and markers
  Map<String, Polyline> polylines = {};
  Polyline currentPolyline;
  Set<Marker> markers = {};
  bool atDelivery = false;

  // info variables
  String directions;
  String stepTimeRemaining;
  DateTime startTime;
  DateTime stepTimeStamp;
  int distance;
  String eta;
  String distanceETA;
  String delivery;
  String deliveryAddress;
  String directionIconPath;

  // Notifications
  Map<String, String> _abnormalityHeaders =
  {
    "offroute": "Going Off Route!",
    "sudden_stop": "Sudden Stop!",
    "stopping_too_long": "You Stopped Moving!",
    "speeding": "You Are Speeding!",
    "driving_too_slow": "You Are Driving Slow!"
  };
  Map<String, String> _abnormalityMessages =
  {
    "offroute": "You are going off the prescribed route.",
    "sudden_stop": "You stopped very quickly. Are you OK?",
    "stopping_too_long": "You have stopped for too long.",
    "speeding": "You are driving above the speed limit.",
    "driving_too_slow": "You are driving slow for a while now."
  };


  NavigationService({this.jsonFile, BuildContext context}) {
    _currentRoute = 0;
    _currentLeg = 0;
    _currentStep = 0;
    initialiseRoutes();
    initialisePolyPointsAndMarkers(_currentRoute);
    initialiseNotifications(context);
  }


  //__________________________________________________________________________________________________
  //                            Initialisation
  //__________________________________________________________________________________________________

  initialiseNotifications(BuildContext context) {
    _notificationManager.initializing(context);
  }

  /*
   * Parameters: none
   * Returns: none
   * Description: Turns json from saved file into DeliveryRoute object.
   *
   */
  initialiseRoutes() async {
    JsonHandler handler = JsonHandler();
    Map<String, dynamic> json = await handler.parseJson(jsonFile);
    _deliveryRoutes = DeliveryRoute.fromJson(json);
  }

  initialisePolyPointsAndMarkers(int route) async {
    if(_deliveryRoutes == null){
      await initialiseRoutes();
    }
    for(int leg = 0; leg < _deliveryRoutes.routes[route].legs.length; leg++){
      int delivery = leg + 1;
      Marker marker = Marker(
        markerId: MarkerId('$route-$leg'),
        position: LatLng(
          _deliveryRoutes.routes[route].legs[leg].endLocation.lat,
          _deliveryRoutes.routes[route].legs[leg].endLocation.lng,
        ),
        infoWindow: InfoWindow(
          title: 'Delivery $delivery',
          snippet: _deliveryRoutes.routes[route].legs[leg].endAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );
      markers.add(marker);

      List<LatLng> polylineCoordinates = [];
      String polyId = "$route-$leg";

      // get polyline points from DeliveryRoute in navigator service
      List<PointLatLng> result = decodeEncodedPolyline(_deliveryRoutes.routes[route].overviewPolyline.points);

      // Adding the coordinates to the list
      if (result.isNotEmpty) {
        result.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }

      // Defining an ID
      PolylineId id = PolylineId(polyId);

      // Initializing Polyline
      Polyline polyline = Polyline(
          polylineId: id,
          color: Colors.purple,
          points: polylineCoordinates,
          width: 10
      );

      // adds polyline to the polylines to be displayed.
      polylines[polyId] = polyline;

    }
    // after all polylines are created set current polyline for navigation.
    setCurrentPolyline();
  }

  initialiseInfoVariables(){
    startTime = DateTime.now();
    eta = getDeliveryArrivalTime();
    int del = _currentLeg + 1;
    delivery = "Delivery $del";
    directions = getDirection();
    stepTimeRemaining = getTimeToDelivery();
    String distance = getDeliveryDistance();
    distanceETA = "$distance . $eta";
    deliveryAddress = getDeliveryAddress();
    directionIconPath = getDirectionIcon();
  }


  //__________________________________________________________________________________________________
  //                            Updates
  //__________________________________________________________________________________________________

  /*
   * Parameters: none
   * Returns: none
   * Description: Creates 2 new polylines with different colours to display that
   *              the driver is moving along the route between the points.
   */
  updateCurrentPolyline(){

    print(polylines["0-0"].points.length);
    print(currentPolyline.points.length);
    LatLng positionOnPoly = calculatePointOnPolyline();

    // remove previous position from polyline
    currentPolyline.points.removeAt(0);

    // determine where on polyline the driver is
    int newLength = 0;
    for(int i = 0; i < currentPolyline.points.length - 1; i ++){
      int dist1 = calculateDistanceBetween(currentPolyline.points[i + 1], LatLng(_position.latitude, _position.longitude));
      int dist2 = calculateDistanceBetween(currentPolyline.points[i], currentPolyline.points[i + 1]);
      if(dist2 > dist1){
        newLength = i + 1;
        _currentStep += 1;
      }
    }

    // remove any previous points
    newLength = currentPolyline.points.length - newLength;
    while(currentPolyline.points.length > 0 && currentPolyline.points.length > newLength){
      currentPolyline.points.removeAt(0);
    }

    // re-add current position
    currentPolyline.points.insert(0, positionOnPoly);
  }


  //__________________________________________________________________________________________________
  //                            Setters
  //__________________________________________________________________________________________________

  setCurrentPolyline(){
    currentPolyline = polylines["$_currentRoute-$_currentLeg"];
  }



  //__________________________________________________________________________________________________
  //                            Getters
  //__________________________________________________________________________________________________

  /*
   * Parameters: none
   * Returns: String
   * Description: Gets street names for directions.
   *              \u003c = opening tag and \u003e = closing tags
   */
  String getDirection(){
    if(_deliveryRoutes == null){
      return "LOADING...";
    }
    return _deliveryRoutes.getHTMLInstruction(_currentRoute, _currentLeg, _currentStep);
  }

  getDirectionIcon(){
    String path = "assets/images/";
    if(_deliveryRoutes == null){
      path += "navigation_marker";
    }

    String direction = _deliveryRoutes.getManeuver(_currentRoute, _currentLeg, _currentStep);

    switch(direction){
      case "turn-right":
        path += "right_turn_arrow";
        break;
      case "roundabout-right":
        path += "right_turn_arrow";
        break;
      case "turn-left":
        path += "left_turn_arrow";
        break;
      case "roundabout-left":
        path += "left_turn_arrow";
        break;
      default:
        path += "straight_arrow";
    }

    //chose color
    path += "_white.png";
    directionIconPath = path;

  } // gets icon to display directions such as right arrow for turn right

  String getTimeToDelivery(){
    if(_deliveryRoutes == null){
      return null;
    }

    int duration = (_deliveryRoutes.getDeliveryDuration(_currentRoute, _currentLeg)/60).ceil();

    return "$duration min";
  } // gets arrival time

  int getStepDistance(){
    if(_deliveryRoutes == null){
      return null;
    }
    return (_deliveryRoutes.getStepDistance(_currentRoute, _currentLeg, _currentStep)/10).round() * 10;
  }

  String getDeliveryDistance(){
    if(_deliveryRoutes == null){
      return null;
    }

    int distance = (_deliveryRoutes.getDeliveryDistance(_currentRoute, _currentLeg)/10).round() * 10;


    if(distance > 1000){
      int km = 0;
      int  m = (distance/100).round() * 100;
      while(m > 1000){
        m -= 1000;
        km += 1;
      }
      m = (m/100).round();

      return "$km,$m km";
    }

    return "$distance m";
  }

  String getDeliveryArrivalTime(){
    if(_deliveryRoutes == null){
      return null;
    }

    int arrivalTime = (_deliveryRoutes.getDeliveryDuration(_currentRoute, _currentLeg)/60).ceil();
    int hours = 0;
    int minutes = 0;
    int temp = arrivalTime;
    if(arrivalTime > 60){
      while(temp > 60){
        temp -= 60;
        hours += 1;
      }
    }
    minutes += temp;
    if(stepTimeStamp == null){
      stepTimeStamp = DateTime.now();
    }

    stepTimeStamp = stepTimeStamp.add(Duration(hours: hours, minutes: minutes));
    hours = stepTimeStamp.hour;
    minutes = stepTimeStamp.minute;

    String hourString;
    String minuteString;
    if(hours < 10){
      hourString = "0$hours";
    }
    else{
      hourString = "$hours";
    }

    if(minutes < 10){
      minuteString = "0$minutes";
    }
    else{
      minuteString = "$minutes";
    }

    eta = "$hourString:$minuteString";

    return eta;
  }

  int getRemainingDeliveries(){
    if(_deliveryRoutes == null){
      return null;
    }
    return getTotalDeliveries() - _currentRoute -1;
  }

  int getTotalDeliveries(){
    if(_deliveryRoutes == null){
      return null;
    }
    return _deliveryRoutes.getTotalDeliveries();
  }

  String getDeliveryAddress(){
    if(_deliveryRoutes == null){
      return "";
    }
    else{
      String address = _deliveryRoutes.getDeliveryAddress(_currentRoute, _currentLeg);
      // cut after second ,

      return address;
    }

  }






  //__________________________________________________________________________________________________
  //                            Calculation functions
  //__________________________________________________________________________________________________

  /*
   * Author: Jordan Nijs
   * Parameters: none
   * Returns: int
   * Description: Uses a current position to determine distance away from next point.
   */
  int calculateDistanceBetween(LatLng currentPosition, LatLng lastPosition){
    double p = 0.017453292519943295;
    double a = 0.5 - cos((currentPosition.latitude - lastPosition.latitude) * p)/2 +
        cos(lastPosition.latitude * p) * cos(currentPosition.latitude * p) *
            (1 - cos((currentPosition.longitude - lastPosition.longitude) * p))/2;
    return (12742 * asin(sqrt(a)) * 1000).round();
  }

  /*
   * Author: dammy_ololade (https://github.com/Dammyololade/flutter_polyline_points/blob/master/lib/src/network_util.dart)
   * Parameters: Google Encoded String
   * Returns: List
   * Description: Decode the google encoded string using Encoded Polyline Algorithm Format.
   *              For more info about the algorithm check  https://developers.google.com/maps/documentation/utilities/polylinealgorithm
   */
  List<PointLatLng> decodeEncodedPolyline(String encoded) {
    List<PointLatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      PointLatLng p =
      new PointLatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }

  LatLng calculatePointOnPolyline(){
    if(currentPolyline == null){
      return null;
    }

    LatLng start = currentPolyline.points[0];
    LatLng end = currentPolyline.points[1];

    // work out perpendicular intersect of line between polyline points and line that goes through current position.
    double m = (end.longitude - start.longitude)/(end.latitude - start.latitude);
    double b = start.longitude - (m * start.latitude);
    double perpendicularM = -1 * (1/m);
    double perpendicularB = _position.longitude - (perpendicularM * _position.latitude);

    double shouldBeAtLat = (b - perpendicularB)/(perpendicularM - m);
    double shouldBeAt = m*(shouldBeAtLat) + b;

    LatLng currentPoint = LatLng(shouldBeAtLat, shouldBeAt);

    return currentPoint;
  }


  //__________________________________________________________________________________________________
  //                            Main Function
  //__________________________________________________________________________________________________

  /*
   * Parameters: Position
   * Returns: int
   * Description: Navigation function that implements all the required steps for navigation.
   */
  navigate(Position currentPosition) {
    /*
    - set current location
    - find the current point
    - check if on route -> if not start creating black poly
    - check if close to step or leg
    - set step/leg as required
    - update current polyline
    - update the info vars for map
     */

    _position = currentPosition;

    // safety checks
    if(currentPolyline == null){
      setCurrentPolyline();
      // uncomment when not using replacement functions from abnormality service
      //_abnormalityService.getSpeedLimit(currentPolyline.points);
    }
    if(directions == null || eta == null || distance == null ||
        distanceETA == null || stepTimeStamp == null ||
        stepTimeRemaining == null || delivery == null || deliveryAddress == null){
      initialiseInfoVariables();
    }




    updateCurrentPolyline();

  }

}