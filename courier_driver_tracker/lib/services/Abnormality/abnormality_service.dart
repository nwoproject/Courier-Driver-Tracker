import 'dart:math';
import 'dart:core';
import 'package:courier_driver_tracker/services/navigation/location.dart';
import 'package:geolocator/geolocator.dart';

class AbnormalityService{
  /*
   * Author: Gian Geyser
   * Description: Service that detects and notifies any abnormalities during deliveries.
   * Gets called inside notification Service
   */

  Position _currentPosition;      // Current position of the Device
  Position _lastPosition;         // Last position of significant movement
  int _minMovingDistance = 20;    // Distance considered to be significant movement
  int _maxStopCount = 100;         // Amount of cycles the driver may stop
  int _stopCount = 0;             // Amount of cycles the driver have stopped
  int _maxSpeedDifference = 40;    // Speed difference between cycles considered to be dangerous
  bool stopped = false;

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

  double calculateDistanceBetween(Position currentPosition, Position lastPosition){
    double p = 0.017453292519943295;
    double a = 0.5 - cos((currentPosition.latitude - lastPosition.latitude) * p)/2 +
        cos(lastPosition.latitude * p) * cos(currentPosition.latitude * p) *
            (1 - cos((currentPosition.longitude - lastPosition.longitude) * p))/2;
    return 12742 * asin(sqrt(a)) * 1000;
  }

  /*
   * Author: Gian Geyser & Jordan Nijs
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
        stopped = true;
        return true;
      }
      else if(distance < _minMovingDistance){
        _stopCount += 1;
      }
      else{
        _lastPosition = _currentPosition;
        _stopCount = 0;
        stopped = false;
      }
      return false;
  }


  /*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: bool
   * Description: Uses the current position and specified route to determine
   *              if the driver is still following the specified route.
   */
  bool offRoute(Location start, Location end){
    double m = (end.lng - start.lng)/(end.lat - start.lat);
    double shouldBeAt = m*(_currentPosition.latitude - start.lat) + start.lng;
    double distanceFromPolyline = calculateDistanceBetween(_currentPosition, Position(longitude: shouldBeAt, latitude: _currentPosition.latitude));

    // checks if the distance of the courier is more than 20m away from route.
    if(distanceFromPolyline > _currentPosition.accuracy + 20){
      return true;
    }
    else{
      return false;
    }
  }


  /*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: bool
   * Description: Uses the current position and last position's speed to determine
   *              if the courier made a sudden stop/decrease in speed between
   *              cycles.
   */
  bool suddenStop(){
    if(!stopped && _lastPosition.speed - _currentPosition.speed > _maxSpeedDifference){
      stopped = true;
      return true;
    }
    return false;
  }
}