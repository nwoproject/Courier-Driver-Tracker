import 'dart:math';
import 'package:courier_driver_tracker/services/abnormality/abnormality_service.dart';
import 'package:courier_driver_tracker/services/file_handling/json_handler.dart';
import 'package:courier_driver_tracker/services/navigation/delivery_route.dart';
import 'package:courier_driver_tracker/services/notification/local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NavigatorService{

  DeliveryRoute _deliveryRoutes;
  int _currentRoute;
  int _currentLeg;
  int _currentStep;
  int _currentPoint;
  String jsonFile;
  LocalNotifications _notificationManager = LocalNotifications();
  AbnormalityService _abnormalityService = AbnormalityService();
  Position _position;

  // Map polylines and markers
  Map<PolylineId, Polyline> polylines = {};
  Polyline currentPolyline;
  Polyline splitPolylineBefore;
  List<LatLng> splitPolylineCoordinatesBefore;
  Polyline splitPolylineAfter;
  List<LatLng> splitPolylineCoordinatesAfter;
  Set<Marker> markers = {};

  NavigatorService({this.jsonFile}){
    getRoutes();
    _currentRoute = 0;
    _currentLeg = 0;
    _currentStep = 0;
    _currentPoint = 0;
  }

  /*
   * Author: Gian Geyser
   * Parameters: Position
   * Returns: int
   * Description: Navigation function that implements all the required steps for navigation.
   */
  navigate(Position currentPosition){
    /*
    - set current location
    - find the current point
    - check if on route -> if not start creating black poly
    - check if close to step or leg
    - set step/leg as required
    - update current polyline
    - update the info vars for map
     */

  }

  /*
   * Author: Jordan Nijs
   * Parameters: none
   * Returns: int
   * Description: Uses a current position to determine distance away from next point.
   */
  int calculateDistanceBetween(Position currentPosition, Position lastPosition){
    double p = 0.017453292519943295;
    double a = 0.5 - cos((currentPosition.latitude - lastPosition.latitude) * p)/2 +
        cos(lastPosition.latitude * p) * cos(currentPosition.latitude * p) *
            (1 - cos((currentPosition.longitude - lastPosition.longitude) * p))/2;
    return 12742 * asin(sqrt(a)) * 1000 as int;
  }

  findCurrentPoint(){}

  moveToNextStep(){}

  moveToNextLeg(){}

  passedStepPoint(){}

  reachedDeliveryPoint(){}

  moveToNextDelivery(){}

  /*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: none
   * Description: Creates 2 new polylines with different colours to display that
   *              the driver is moving along the route between the points.
   */
  updateCurrentPolyline(){
    // remove previous position from before and after polyline
    splitPolylineCoordinatesBefore.removeLast();
    splitPolylineCoordinatesAfter.removeAt(0);

    while(splitPolylineCoordinatesBefore.length < _currentPoint){
      splitPolylineCoordinatesBefore.add(splitPolylineCoordinatesAfter.removeAt(0));
    }
    splitPolylineCoordinatesAfter.insertAll(0,[LatLng(_position.latitude, _position.longitude)]);
    splitPolylineCoordinatesBefore.add(LatLng(_position.latitude, _position.longitude));
    splitPolylineBefore = Polyline(
      polylineId: splitPolylineBefore.polylineId,
      color: Colors.purple[200],
      points: splitPolylineCoordinatesBefore,
      width: 5
    );
    splitPolylineAfter = Polyline(
      polylineId: splitPolylineAfter.polylineId,
      color: Colors.purple,
      points: splitPolylineCoordinatesAfter,
      width: 5
    );
  } // create new polylines for map to show the route already traveled

  /*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: none
   * Description: After driver has reached the next step update the previous
   *              polyline to show the step has been completed.
   */
  updatePreviousStepPolyline(){
    // remove before and after split polys
    polylines.remove(splitPolylineBefore.polylineId);
    polylines.remove(splitPolylineAfter.polylineId);

    // add the delivery route again with lighter colour
    polylines[currentPolyline.polylineId] = Polyline(
      polylineId: currentPolyline.polylineId,
      color: Colors.purple[200],
      points: currentPolyline.points,
      width: 5
    );
  } // change the previous delivery route polyline colour to show the delivery has been comleted


  /*
  * -- Getters --
  */
  DeliveryRoute getDeliveryRoute(){
    return _deliveryRoutes;
  }

  int getStep(){
    return _currentStep;
  }

  int getLeg(){
    return _currentLeg;
  }

  int getDelivery(){
    return _currentRoute;
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


  String getNextDirection(){
    return _deliveryRoutes.getHTMLInstruction(_currentRoute, _currentLeg, _currentStep + 1);
  } // gets the next directions

  /*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: String
   * Description: Gets street names for directions.
   *              \u003c = opening tag and \u003e = closing tags
   */
  String getDirection(){
    return _deliveryRoutes.getHTMLInstruction(_currentRoute, _currentLeg, _currentStep);
  }

  getDirectionIcon(){
    String direction = _deliveryRoutes.getManeuver(_currentRoute, _currentLeg, _currentStep);
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

  int getArrivalTime(){
    return _deliveryRoutes.getDuration(_currentRoute, _currentLeg, _currentStep);
  } // gets arrival time

  int getDistance(){
    return _deliveryRoutes.getDistance(_currentRoute, _currentLeg, _currentStep);
  }

  getDeliveryArrivalTime(){
    return _deliveryRoutes.getDeliveryDuration(_currentRoute, _currentLeg);
  } // gets arrival time
  getDeliveryDistance(){
    return _deliveryRoutes.getDeliveryDistance(_currentRoute, _currentLeg);
  }

  int getRemainingDeliveries(){
    return getTotalDeliveries() - _currentRoute -1;
  }

  int getTotalDeliveries(){
    return _deliveryRoutes.getTotalDeliveries();
  }


  /*
  * -- Setters --
  */
  setRouteFilename(String filename){
    jsonFile = filename;
  }

  updateCurrentPosition(Position position){
    _position = position;
  }

  setInitialPolyPointsAndMarkers(int route){
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
      for(int step = 0; step < _deliveryRoutes.routes[route].legs[leg].steps.length; step++){
        List<LatLng> polylineCoordinates = [];
        String polyId = "$route-$leg-$step";

        // get polyline points from DeliveryRoute in navigator service
        List<PointLatLng> result = decodeEncodedPolyline(_deliveryRoutes.routes[route].legs[leg].steps[step].polyline.points);

        // Adding the coordinates to the list
        if (result.isNotEmpty) {
          int numPolyPoints = 0;
          result.forEach((PointLatLng point) {
            numPolyPoints += 1;
            print(numPolyPoints);
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
          width: 5,
        );

        // adds polyline to the polylines to be displayed.
        polylines[id] = polyline;
      }
    }
    // after all polylines are created set current polyline and split it for navigation.
    setCurrentPolyline();
    setCurrentSplitPolylines();
  }

  setCurrentPolyline(){
    currentPolyline = polylines.remove(polylines["$_currentRoute-$_currentLeg-$_currentStep"].polylineId);
  }

  setCurrentSplitPolylines(){
    splitPolylineCoordinatesBefore = [];
    splitPolylineCoordinatesAfter.add(LatLng(_position.latitude, _position.longitude));
    splitPolylineCoordinatesAfter.addAll(currentPolyline.points);

    PolylineId polyBeforeID = PolylineId("$_currentRoute-$_currentLeg-$_currentStep-before");
    PolylineId polyAfterID = PolylineId("$_currentRoute-$_currentLeg-$_currentStep-after");

    splitPolylineBefore = Polyline(
        polylineId: polyBeforeID,
        color: Colors.purple[200],
        points: splitPolylineCoordinatesBefore,
        width: 5
    );
    splitPolylineAfter = Polyline(
        polylineId: polyAfterID,
        color: Colors.purple,
        points: splitPolylineCoordinatesAfter,
        width: 5
    );

    // add split polys to the polylines
    polylines[polyBeforeID] = splitPolylineBefore;
    polylines[polyAfterID] = splitPolylineAfter;
  }

}

/*
TODO
  - check if close enough to step
  - check if close enough to leg
  - check where the driver is between points
  - write function to handle the navigation checks above
  - if off route add black poly where they drive

 */