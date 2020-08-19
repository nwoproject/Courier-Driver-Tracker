import 'dart:convert';
import 'dart:math';
import 'dart:core';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class AbnormalityService{
  /*
   * Author: Gian Geyser
   * Description: Service that detects and notifies any abnormalities during deliveries.
   * Gets called inside notification Service
   */

  Position _currentPosition;      // Current position of the Device
  Position _lastPosition;         // Last position of significant movement
  int _minMovingDistance = 200;    // Distance considered to be significant movement
  int _maxStopCount = 450;         // Amount of cycles the driver may stop
  int _stopCount = 0;             // Amount of cycles the driver have stopped
  int _maxSpeedDifference = 40;    // Speed difference between cycles considered to be dangerous
  var _speedLimits;
  int _slowCount = 0;
  int _maxSlowCount = 150;
  int _speedingCount = 0;
  int _maxSpeedingCount = 3;
  bool _stopped = false;
  bool _wentOffRoute = false;
  bool _stillOffRoute = false;


  void setCurrentLocation(Position position){
    _currentPosition = position;
    if(_lastPosition == null){
      _lastPosition = position;
    }
  }
  Position getCurrentLocation(){
    return _currentPosition;
  }

  void setLastLocation(Position position){
    _lastPosition = position;
  }
  Position getLastLocation(){
    return _lastPosition;
  }

  void setMaxStopCount(int i){
    _maxStopCount = i;
  }

  bool getStillOffRoute(){
    return _stillOffRoute;
  }

  setStillOffRoute(bool off){
    _stillOffRoute = off;
  }

  double calculateDistanceBetween(Position currentPosition, Position lastPosition){
    double p = 0.017453292519943295;
    double a = 0.5 - cos((currentPosition.latitude - lastPosition.latitude) * p)/2 +
        cos(lastPosition.latitude * p) * cos(currentPosition.latitude * p) *
            (1 - cos((currentPosition.longitude - lastPosition.longitude) * p))/2;
    return 12742 * asin(sqrt(a)) * 1000;
  }

  getSpeedLimit(List<LatLng> points) async {
    if(points == null){
      print("Dev: setSpeedLimit received null");
      return;
    }

    String polyPoints = "";
    points.forEach((element) {
      polyPoints += element.latitude.toString() + "," + element.longitude.toString();
      if(element != points.last){
        polyPoints += "|";
      }
    });

    if(polyPoints == null || polyPoints.length == 0){
      print("Dev: Error occurred while trying to retrieve speed limit.");
      return;
    }

    String key = String.fromEnvironment('APP_MAP_API_KEY', defaultValue: DotEnv().env['APP_MAP_API_KEY']);
    print(key);

    var params = {
      "path" : polyPoints,
      "key" : key
    };

    Uri uri = Uri.https("roads.googleapis.com", "v1/speedLimits", params);
    String url = uri.toString();
    print('GOOGLE ROADS URL: ' + url);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      _speedLimits = json.decode(response.body);
      print(_speedLimits);
    }
    else{
      print("Dev: Google Route API called failed.");
      print(response.body);
    }
  }

  /*
   * Parameters: none
   * Returns: bool
   * Description: Uses the current position and last position to determine
   *              the distance traveled. Creates a notification if the position
   *              has not sufficiently moved within the specified
   *              cycles(_maxStopCount).
   */
  bool stoppingTooLong(){
      double distance = calculateDistanceBetween(_currentPosition, _lastPosition);
      if(_stopCount >= _maxStopCount && distance < _minMovingDistance) {
        _stopCount = 0;
        _stopped = true;
        return true;
      }
      else if(distance < _minMovingDistance){
        _stopCount += 1;
      }
      else{
        _lastPosition = _currentPosition;
        _stopCount = 0;
        _stopped = false;
      }
      return false;
  }


  /*
   * Parameters: none
   * Returns: bool
   * Description: Uses the current position and specified route to determine
   *              if the driver is still following the specified route.
   */
  bool offRoute(LatLng start, LatLng end){
    double m = (end.longitude - start.longitude)/(end.latitude - start.latitude);
    double shouldBeAt = m*(_currentPosition.latitude - start.latitude) + start.longitude;
    double distanceFromPolyline = calculateDistanceBetween(_currentPosition, Position(longitude: shouldBeAt, latitude: _currentPosition.latitude));

    // checks if the distance of the courier is more than 20m away from route.
    if(distanceFromPolyline > _currentPosition.accuracy + 20){
      if(_wentOffRoute){
        if(!_stillOffRoute){
          _stillOffRoute = true;
        }
      }
      _wentOffRoute = true;
      return true;
    }
    else{
      if(_wentOffRoute){
        _wentOffRoute = false;
        _stillOffRoute = false;
      }
      return false;
    }
  }


  /*
   * Parameters: none
   * Returns: bool
   * Description: Uses the current position and last position's speed to determine
   *              if the courier made a sudden stop/decrease in speed between
   *              cycles.
   */
  bool suddenStop(){
    if(!_stopped && _lastPosition.speed - _currentPosition.speed > _maxSpeedDifference){
      _stopped = true;
      return true;
    }
    return false;
  }

  bool isSpeeding(int currentPoint){
    if(_speedLimits == null){
      print("Dev: No speed limits set for speeding Abnormality.");
      return false;
    }

    if(_speedingCount >= _maxSpeedingCount){
      return true;
    }
    else if(_currentPosition.speed  > _speedLimits["speedLimits"][currentPoint]["speedLimit"] + 10.0){
      _speedingCount += 1;
      return false;
    }
    else{
      _speedingCount = 0;
      return false;
    }
  }

  bool drivingTooSlow(int currentPoint){
    if(_speedLimits == null){
      print("Dev: No speed limits set for drivingTooSlow Abnormality.");
      return false;
    }

    if(_slowCount >= _maxSlowCount){
      return true;
    }
    else if(_currentPosition.speed < _speedLimits["speedLimits"][currentPoint]["speedLimit"] * 0.5){
      _slowCount += 1;
      return false;
    }
    else{
      _slowCount = 0;
      return false;
    }
  }

  /*
   Temporary replacement functions for the two above, due to lack of Asset
   Tracking License. If deploying system and app, Google sales should be
   contacted to acquire the license and the replacement function in the navigator
   services Navigate function should be replaced with the actual functions.
   */
  bool drivingTooSlowTemp(){
    if(_slowCount >= _maxSlowCount){
      return true;
    }
    else if(_currentPosition.speed < 110 * 0.5){
      _slowCount += 1;
      return false;
    }
    else{
      _slowCount = 0;
      return false;
    }
  }

  bool isSpeedingTemp(){
    if(_speedingCount >= _maxSpeedingCount){
      return true;
    }
    else if(_currentPosition.speed > 110.0){
      _speedingCount += 1;
      return false;
    }
    else{
      _speedingCount = 0;
      return false;
    }
  }

  bool drivingWithoutDelivery(){
    return false;
  }
}