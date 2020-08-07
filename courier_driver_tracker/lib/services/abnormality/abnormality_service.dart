import 'dart:math';
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
   * Returns: none
   * Description: Uses the current position and specified route to determine
   *              if the driver is still following the specified route.
   */
  void offRoute(){

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
    if(!stopped && _lastPosition.speed - _currentPosition.speed > _maxSpeedDifference){
      stopped = true;
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