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
  /*
   * Author: Gian Geyser
   * Description: Navigation class.
   */

  DeliveryRoute _deliveryRoutes;
  int _currentRoute;
  int _currentLeg;
  int _currentStep;
  int _currentPoint;
  int _stepStartPoint;
  int _stepEndPoint;
  String jsonFile;
  LocalNotifications _notificationManager = LocalNotifications();
  AbnormalityService _abnormalityService = AbnormalityService();
  Position _position;
  bool _doneWithDelivery;

  // Map polylines and markers
  Map<String, Polyline> polylines = {};
  Polyline currentPolyline;
  Polyline splitPolylineBefore;
  List<LatLng> splitPolylineCoordinatesBefore;
  Polyline splitPolylineAfter;
  List<LatLng> splitPolylineCoordinatesAfter;
  Set<Marker> markers = {};

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
    "offroute" : "Going Off Route!",
    "sudden_stop" : "Sudden Stop!",
    "stopping_too_long" : "You Stopped Moving!",
    "speeding" : "You Are Speeding!",
    "driving_too_slow" : "You Are Driving Slow!"
  };
  Map<String, String> _abnormalityMessages =
  {
    "offroute" : "You are going off the prescribed route.",
    "sudden_stop" : "You stopped very quickly. Are you OK?",
    "stopping_too_long" : "You have stopped for too long.",
    "speeding" : "You are driving above the speed limit.",
    "driving_too_slow" : "You are driving slow for a while now."
  };


  NavigatorService({this.jsonFile, BuildContext context}){
    _currentRoute = 0;
    _currentLeg = 0;
    _currentStep = 0;
    _currentPoint = 0;
    getRoutes();
    setInitialPolyPointsAndMarkers(_currentRoute);
    initialiseNotifications(context);
  }

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
    _abnormalityService.setCurrentLocation(currentPosition);
    if(currentPolyline == null){
      setCurrentPolyline();
      // uncomment when not using replacement functions from abnormality service
      //_abnormalityService.getSpeedLimit(currentPolyline.points);
    }
    if(splitPolylineAfter == null || splitPolylineBefore == null){
      setCurrentSplitPolylines();
    }
    if(directions == null || eta == null || distance == null ||
        distanceETA == null || stepTimeStamp == null ||
        stepTimeRemaining == null || delivery == null || deliveryAddress == null){
      setInitialInfoVariables();
    }
    if(directionIconPath == null){
      getDirectionIcon();
    }
    // find where in the delivery the driver is.
    findCurrentPoint();
    LatLng current = currentPolyline.points[_currentPoint];
    LatLng next;
    if(_currentPoint < currentPolyline.points.length -1){
      next = currentPolyline.points[_currentPoint + 1];
    }
    else if(_currentPoint == currentPolyline.points.length - 1 && _currentLeg < _deliveryRoutes.routes[_currentRoute].legs.length - 1){
      int nextLeg = _currentLeg + 1;
      next = getPolyline("$_currentRoute-$nextLeg").points[0];
    }
    else{
      current = currentPolyline.points[_currentPoint - 1];
      next = currentPolyline.points[_currentPoint];
    }

    if(_stepStartPoint == null || _stepEndPoint == null ){
      findStepStartPoint();
      findStepEndPoint();
    }
    if(_currentPoint == 0){
      directions = getDirection();
      getDirectionIcon();
    }

    // check if on the route
    if(!_abnormalityService.offRoute(current, next)){
      if(_currentPoint > _stepEndPoint){
        moveToNextStep();
      }
      else{
        updateCurrentPolyline();
      }
      // set info vars

    }
    else{
      // making sure only on notification gets sent.
      if(!_abnormalityService.getStillOffRoute()){
        _notificationManager.report = "offRoute";
        _notificationManager.showNotifications(_abnormalityHeaders["offroute"], _abnormalityMessages["offroute"]);
      }
      //start marking the route he followed.
    }

    //update info
    updateDistanceETA();
    updateStepTimeRemaining();

    // call abnormalities
    if(_abnormalityService.suddenStop()){
      _notificationManager.report = "sudden";
      _notificationManager.showNotifications(_abnormalityHeaders["sudden_stop"], _abnormalityMessages["sudden_stop"]);
    }
    if(_abnormalityService.stoppingTooLong()){
      _notificationManager.report = "long";
      _notificationManager.showNotifications(_abnormalityHeaders["stopping_too_long"], _abnormalityMessages["stopping_too_long"]);
    }
    /*
    Temp functions being called to be replaced before actual deployment.
     For more information about this see the AbnormalityService class as well
     as the
     */
    if(_abnormalityService.isSpeedingTemp()){
      _notificationManager.report = "speeding";
      _notificationManager..showNotifications(_abnormalityHeaders["speeding"], _abnormalityMessages["speeding"]);
    }
    if(_abnormalityService.drivingTooSlowTemp()){
      _notificationManager.report = "slow";
      //_notificationManager..showNotifications(_abnormalityHeaders["driving_too_slow"], _abnormalityMessages["driving_too_slow"]);
    }
  }

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

  int calculateTimeToNextDelivery(){
    int times = 0;
    for(int step = 0; step < _currentStep; step++){
      times += _deliveryRoutes.routes[_currentRoute].legs[_currentLeg].steps[step].duration;
    }

    return ((getDeliveryArrivalTime() - times)/60 * distance/getDistance()).ceil();
  }

  String calculateETA(){
    if(startTime == null){
      startTime = DateTime.now();
    }
    int arrivalTime = (getDeliveryArrivalTime()/60).ceil();
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

  /*
   * Parameters: none
   * Returns: none
   * Description: Determines the point within the step where the driver is at.
   *              Used to split the polyline for UI purposes.
   */
  findCurrentPoint(){
    for(int i = 0; i < currentPolyline.points.length -1; i++){
      double d1 = sqrt(pow((_position.latitude - currentPolyline.points[i].latitude),2) + pow(_position.longitude - currentPolyline.points[i].longitude,2));
      double d2 = sqrt(pow((currentPolyline.points[i+1].latitude - currentPolyline.points[i].latitude),2) + pow(currentPolyline.points[i+1].longitude - currentPolyline.points[i].longitude,2));

      if(d1 < d2){
        _currentPoint = i;
        return;
      }
    }
    _currentPoint = currentPolyline.points.length;
  }

  findStepStartPoint(){
    LatLng start = LatLng(_deliveryRoutes.routes[_currentRoute].legs[_currentLeg].steps[_currentStep].startLocation.lat,
        _deliveryRoutes.routes[_currentRoute].legs[_currentLeg].steps[_currentStep].startLocation.lng);
    for(int i = 0; i < currentPolyline.points.length; i++){
      if(calculateDistanceBetween(start, currentPolyline.points[i]) < 1){
        _stepStartPoint = i;
        return;
      }
    }
  }

  findStepEndPoint(){
    LatLng start = LatLng(_deliveryRoutes.routes[_currentRoute].legs[_currentLeg].steps[_currentStep].endLocation.lat,
        _deliveryRoutes.routes[_currentRoute].legs[_currentLeg].steps[_currentStep].endLocation.lng);
    for(int i = 0; i < currentPolyline.points.length; i++){
      if(calculateDistanceBetween(start, currentPolyline.points[i]) < 1){
        _stepEndPoint = i;
        return;
      }
    }
  }

  bool reachedDeliveryPoint(){
    // if point is last and distance is close enough
    return false;
  }

  moveToNextStep(){
    if(_currentPoint == currentPolyline.points.length) {
      moveToNextLeg();
    }
    else{
      _currentStep += 1;
      findStepStartPoint();
      findStepEndPoint();

      //Setinfo variables
      directions = getDirection();
      int arrivalTime = (getDeliveryArrivalTime()/60).round();
      stepTimeRemaining = "$arrivalTime min";
      distance = getDistance();
      distanceETA = "$distance . $eta";
      getDirectionIcon();

      // uncomment when not using replacement functions from abnormality service
      //_abnormalityService.getSpeedLimit(currentPolyline.points);
    }
  }

  moveToNextLeg(){
    if(_currentPoint == currentPolyline.points.length &&
        _currentLeg < _deliveryRoutes.routes[_currentRoute].legs.length - 1 && _doneWithDelivery){
      _currentLeg += 1;

      _currentStep = 0;
      findStepStartPoint();
      findStepEndPoint();

      updatePreviousLegPolyline();
      setCurrentPolyline();
      setCurrentSplitPolylines();

      stepTimeStamp = DateTime.now();
      setInitialInfoVariables();

      _doneWithDelivery = false;
    }
  }


  /*
   * Parameters: none
   * Returns: none
   * Description: Creates 2 new polylines with different colours to display that
   *              the driver is moving along the route between the points.
   */
  updateCurrentPolyline(){
    // remove previous position from before and after polyline
    splitPolylineCoordinatesBefore.removeLast();
    splitPolylineCoordinatesAfter.removeAt(0);

    while(splitPolylineCoordinatesBefore.length < _currentPoint + 1){
      splitPolylineCoordinatesBefore.add(splitPolylineCoordinatesAfter.removeAt(0));
    }

    splitPolylineCoordinatesBefore.add(getPointOnPolyline());
    splitPolylineCoordinatesAfter.insert(0, getPointOnPolyline());
    String beforeId = "$_currentRoute-$_currentLeg-$_currentStep-before";
    String afterId = "$_currentRoute-$_currentLeg-$_currentStep-after";
    splitPolylineBefore = Polyline(
      polylineId: PolylineId(beforeId),
      color: Colors.green[200],
      points: splitPolylineCoordinatesBefore,
      width: 10
    );
    splitPolylineAfter = Polyline(
      polylineId: PolylineId(afterId),
      color: Colors.purple,
      points: splitPolylineCoordinatesAfter,
      width: 10
    );

    polylines.remove(beforeId);
    polylines.remove(afterId);
    polylines[beforeId] = splitPolylineBefore;
    polylines[afterId] = splitPolylineAfter;
  }

  /*
   * Parameters: none
   * Returns: none
   * Description: After driver has reached the next step update the previous
   *              polyline to show the step has been completed.
   */
  updatePreviousLegPolyline(){
    // remove before and after split polys
    polylines.remove(splitPolylineBefore.polylineId.value);
    polylines.remove(splitPolylineAfter.polylineId.value);
    // add the delivery route again with lighter colour
    polylines[currentPolyline.polylineId.value] = Polyline(
      polylineId: currentPolyline.polylineId,
      color: Colors.green[200],
      points: currentPolyline.points,
      width: 10
    );
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

  updateDistanceToTravel(){
    int totalDistanceTravelled = 0;
    for(int i = 0; i < _currentPoint - 1; i++){
     totalDistanceTravelled += calculateDistanceBetween(currentPolyline.points[i], currentPolyline.points[i + 1]);
    }
    totalDistanceTravelled += calculateDistanceBetween(LatLng(_position.latitude, _position.longitude), currentPolyline.points[_currentPoint]);

    distance = ((getDistance() - totalDistanceTravelled)/10).round() * 10;
  }

  updateDistanceETA(){
    if(eta == null || eta.length == 0){
      eta = calculateETA();
    }
    updateDistanceToTravel();
    if(distance < 1000){
      distanceETA = "$distance m . $eta";
    }

    int km = 0;
    int m = distance;
    while(m > 1000){
      km += 1;
      m -= 1000;
    }
    if(km > 0){
      m = (m/100).round();
      distanceETA = "$km,$m Km . $eta";
    }
  }

  updateStepTimeRemaining(){
    int timeRemaining = calculateTimeToNextDelivery();
    stepTimeRemaining = "$timeRemaining min";
  }

  updateDeliveryAddress(){
    String address = getDeliveryAddress();
    List<String> delAddress = address.split(",");
    if(delAddress.length > 2){
      deliveryAddress =  delAddress[0] + "," + delAddress[1];
    }
    else{
      deliveryAddress =  delAddress[0];
    }
  }

  /*
  *     ---- Getters ----
  */
  DeliveryRoute getDeliveryRoute(){
    return _deliveryRoutes;
  }

  int getStep(){
    return _currentStep;
  }

  int getStepStartPoint(){
    return _stepStartPoint;
  }

  int getStepEndPoint(){
    return _stepEndPoint;
  }

  int getLeg(){
    return _currentLeg;
  }

  int getDelivery(){
    return _currentRoute;
  }

  Polyline getPolyline(String id){
    return polylines.remove(id);
  }

  /*
   * Parameters: none
   * Returns: none
   * Description: Turns json from saved file into DeliveryRoute object.
   *
   */
  getRoutes()  async {
    JsonHandler handler = JsonHandler();
    Map<String, dynamic> json = await handler.parseJson(jsonFile);
    _deliveryRoutes = DeliveryRoute.fromJson(json);
  }

  String getNextDirection(){
    if(_deliveryRoutes == null){
      return "LOADING...";
    }
    return _deliveryRoutes.getHTMLInstruction(_currentRoute, _currentLeg, _currentStep + 1);
  } // gets the next directions

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
    int distFromStart;
    int distFromEnd;
    int displayNextDirectionFromStartDistance = 15;
    int displayNextDirectionFromEndDistance = 15;
    if(_currentPoint == 0){
      distFromStart = calculateDistanceBetween(LatLng(_position.latitude, _position.longitude) , currentPolyline.points[_currentPoint]);
    }
    else if(_currentPoint == currentPolyline.points.length -2){
      distFromEnd = calculateDistanceBetween(LatLng(_position.latitude, _position.longitude) , currentPolyline.points.last);
    }

    if((distFromStart != null && distFromStart < displayNextDirectionFromStartDistance) || _currentStep == _deliveryRoutes.routes[_currentRoute].legs[_currentLeg].steps.length -1){
      if(_currentPoint == currentPolyline.points.length -2 && distFromEnd < displayNextDirectionFromEndDistance){
        return "ARRIVED AT DESTINATION";
      }
      return _deliveryRoutes.getHTMLInstruction(_currentRoute, _currentLeg, _currentStep);
    }
    else{
      return _deliveryRoutes.getHTMLInstruction(_currentRoute, _currentLeg, _currentStep + 1);
    }

  }

  getDirectionIcon(){
    String path = "assets/images/";
    if(_deliveryRoutes == null){
      path += "navigation_marker";
    }
    int distFromStart;
    int displayNextDirectionFromStartDistance = 15;
    String direction;
    if(_currentPoint == 0){
      distFromStart = calculateDistanceBetween(LatLng(_position.latitude, _position.longitude) , currentPolyline.points[_currentPoint]);
    }

    if((distFromStart != null && distFromStart < displayNextDirectionFromStartDistance) || _currentStep == _deliveryRoutes.routes[_currentRoute].legs[_currentLeg].steps.length -1){
      direction = _deliveryRoutes.getManeuver(_currentRoute, _currentLeg, _currentStep);
    }
    else{
      direction = _deliveryRoutes.getManeuver(_currentRoute, _currentLeg, _currentStep + 1);
    }

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

  int getArrivalTime(){
    if(_deliveryRoutes == null){
      return null;
    }
    return _deliveryRoutes.getDuration(_currentRoute, _currentLeg, _currentStep);
  } // gets arrival time

  int getDistance(){
    if(_deliveryRoutes == null){
      return null;
    }
    return _deliveryRoutes.getDistance(_currentRoute, _currentLeg, _currentStep);
  }

  int getDeliveryArrivalTime(){
    if(_deliveryRoutes == null){
      return null;
    }
    return _deliveryRoutes.getDeliveryDuration(_currentRoute, _currentLeg);
  }

  int getDeliveryDistance(){
    if(_deliveryRoutes == null){
      return null;
    }
    return _deliveryRoutes.getDeliveryDistance(_currentRoute, _currentLeg);
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
      return _deliveryRoutes.getDeliveryAddress(_currentRoute, _currentLeg);
    }

  }

  LatLng getPointOnPolyline(){
    if(currentPolyline == null){
      return null;
    }
    LatLng start = currentPolyline.points[_currentPoint];
    LatLng end;
    if(_currentStep == _deliveryRoutes.routes[_currentRoute].legs[_currentLeg].steps.length - 1){
      if(_currentLeg == _deliveryRoutes.routes[_currentRoute].legs.length - 1){
        int next = _currentLeg + 1;
        end = getPolyline("$_currentRoute-$next-0").points[0];
      }
      else{
        int next = _currentStep + 1;
        end = getPolyline("$_currentRoute-$_currentLeg-$next").points[0];
      }
    }
    else{
      end = currentPolyline.points[_currentPoint + 1];
    }

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

  /*
  *   ---- Setters ----
  */
  setRouteFilename(String filename){
    jsonFile = filename;
  }

  updateCurrentPosition(Position position){
    _position = position;
  }

  setInitialPolyPointsAndMarkers(int route) async {
    if(_deliveryRoutes == null){
      await getRoutes();
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
    // after all polylines are created set current polyline and split it for navigation.
  }

  setCurrentPolyline(){
    currentPolyline = polylines.remove("$_currentRoute-$_currentLeg");
  }

  setCurrentSplitPolylines(){
    if(_position == null || currentPolyline == null){
      return;
    }

    splitPolylineCoordinatesBefore = [];
    splitPolylineCoordinatesAfter = [];
    LatLng pointOnPoly = getPointOnPolyline();
    splitPolylineCoordinatesBefore.add(currentPolyline.points.first);
    splitPolylineCoordinatesBefore.add(pointOnPoly);
    splitPolylineCoordinatesAfter.add(pointOnPoly);
    splitPolylineCoordinatesAfter.addAll(currentPolyline.points);
    splitPolylineCoordinatesAfter.removeAt(0);

    PolylineId polyBeforeID = PolylineId("$_currentRoute-$_currentLeg-before");
    PolylineId polyAfterID = PolylineId("$_currentRoute-$_currentLeg-after");

    splitPolylineBefore = Polyline(
        polylineId: polyBeforeID,
        color: Colors.green[200],
        points: splitPolylineCoordinatesBefore,
        width: 10
    );
    splitPolylineAfter = Polyline(
        polylineId: polyAfterID,
        color: Colors.purple,
        points: splitPolylineCoordinatesAfter,
        width: 10
    );

    // add split polys to the polylines
    polylines[polyBeforeID.value] = splitPolylineBefore;
    polylines[polyAfterID.value] = splitPolylineAfter;
  }

  initialiseNotifications(BuildContext context){
    _notificationManager.initializing(context);
  }

  setNotificationContext(BuildContext context){
    _notificationManager.setContext(context);
  }

  setInitialInfoVariables(){
    startTime = DateTime.now();
    eta = calculateETA();
    int del = _currentLeg + 1;
    delivery = "Delivery $del";
    directions = getDirection();
    int arrivalTime = (getArrivalTime()/60).round();
    stepTimeRemaining = "$arrivalTime min";
    int distance = getDistance();
    distanceETA = "$distance . $eta";
    updateDeliveryAddress();
    getDirectionIcon();
  }

}

/*
TODO
  - when point is bigger than step end, move to next step, update everything
    - step start and end,
    - directions and icon,
    - time to next step.
  - if off route add black poly where they drive
  - integrate API
 */