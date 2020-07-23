import 'dart:math';

import 'package:courier_driver_tracker/services/location/deliveries.dart';
import 'package:geolocator/geolocator.dart';

class AbnormalityService{
  /*
   * Author: Gian Geyser
   * Description: Service that detects and notifies any abnormalities during deliveries.
   */

  Position _currentPosition;      // Current position of the Device
  Position _lastPosition;         // Last position of significant movement
  int _minMovingDistance = 20;    // Distance considered to be significant movement
  int _maxStopCount = 100;         // Amount of cycles the driver may stop
  int _stopCount = 0;             // Amount of cycles the driver have stopped
  int _maxSpeedDifference = 1;    // Speed difference between cycles considered to be dangerous
  Deliveries deliveries;
  bool suddenStopped = false;


  void setDeliveries(Deliveries deliveries){
    this.deliveries = deliveries;
  }
  void setCurrentLocation(Position position){
    _currentPosition = position;
    if(_lastPosition == null){
      _lastPosition = position;
    }
  }

  void setLastLocation(Position position){
    _lastPosition = position;
  }

  Position getCurrentLocation(){
    return _currentPosition;
  }

  Position getLastLocation(){
    return _lastPosition;
  }

  void setMaxStopCount(int i){
    _maxStopCount = i;
  }


  /*
   * Author: Gian Geyser & Jordan Nijs
   * Parameters: none
   * Returns: none
   * Description: Uses the current position and last position to determine
   *              the distance traveled. Creates a notification if the position
   *              has not sufficiently moved within the specified
   *              cycles(_maxStopCount).
   */
  bool stoppingTooLong(){
      double p = 0.017453292519943295;
      double a = 0.5 - cos((_currentPosition.latitude - _lastPosition.latitude) * p)/2 +
          cos(_lastPosition.latitude * p) * cos(_currentPosition.latitude * p) *
              (1 - cos((_currentPosition.longitude - _lastPosition.longitude) * p))/2;
      double distance = 12742 * asin(sqrt(a)) * 1000;
      if(_stopCount >= _maxStopCount && distance < _minMovingDistance) {
        _stopCount = 0;
        return true;
      }
      else if(distance < 10){
        _stopCount += 1;
      }
      else{
        _lastPosition = _currentPosition;
        suddenStopped = false;
      }
      return false;

  }


  /*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: none
   * Description: Uses the current position and specified route to determine
   *              if the driver is still following the specified route.
   */
  void offRoute(){
    /*
    double closestLatBefore = deliveries.route[0].coordinates[0][0];
    double closestLongBefore = deliveries.route[0].coordinates[0][1];
    double closestLatAfter = deliveries.route[0].coordinates[1][0];
    double closestLongAfter = deliveries.route[0].coordinates[1][1];

    for(Delivery del in deliveries.route){
      for(List<double> each in del.coordinates){

      }
    }

     */

  }


  /*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: none
   * Description: Uses the current position and last position's speed to determine
   *              if the courier made a sudden stop/decrease in speed between
   *              cycles.
   */
  bool suddenStop(){
    if(_lastPosition.speed - _currentPosition.speed > _maxSpeedDifference && !suddenStopped){
      suddenStopped = true;
      return true;
    }
    return false;
  }


  /*
   * Author: Gian Geyser
   * Parameters: Position object of the couriers current position.
   * Returns: none
   * Description: Sets the current position and last position if not set, then
   *              calls all the abnormality functions.
   */
  void checkAllAbnormalities(Position currentPosition){
    _currentPosition = currentPosition;
    if(_lastPosition == null){
      _lastPosition = currentPosition;
    }
    suddenStop();
    offRoute();
    stoppingTooLong();
  }

}