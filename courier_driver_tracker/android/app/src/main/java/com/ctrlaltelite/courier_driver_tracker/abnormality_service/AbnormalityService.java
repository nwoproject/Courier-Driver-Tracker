package com.ctrlaltelite.courier_driver_tracker.abnormality_service;

import android.location.Location;



public class AbnormalityService {
    /*
     * Author: Gian Geyser
     * Description: Service that detects and notifies any abnormalities during deliveries.
     */

    Location _currentPosition;      // Current position of the Device
    Location _lastPosition;         // Last position of significant movement
    int _minMovingDistance = 20;    // Distance considered to be significant movement
    int _maxStopCount = 10;         // Amount of cycles the driver may stop
    int _stopCount = 0;             // Amount of cycles the driver have stopped
    int _maxSpeedDifference = 40;   // Speed difference between cycles considered to be dangerous


    /*
     * Author: Gian Geyser & Jordan Nijs
     * Parameters: none
     * Returns: none
     * Description: Uses the current position and last position to determine
     *              the distance traveled. Creates a notification if the position
     *              has not sufficiently moved within the specified
     *              cycles(_maxStopCount).
     */
    void stoppingTooLong(){
        double p = 0.017453292519943295;
        double a = 0.5 - Math.cos((_currentPosition.getLatitude() - _lastPosition.getLatitude()) * p)/2 +
                Math.cos(_lastPosition.getLatitude() * p) * Math.cos(_currentPosition.getLatitude() * p) *
                        (1 - Math.cos((_currentPosition.getLongitude() - _lastPosition.getLongitude()) * p))/2;
        double distance = 12742 * Math.asin(Math.sqrt(a)) * 1000;
        if(_stopCount > _maxStopCount && distance < _minMovingDistance) {
            notify("stoppingTooLong");
            _stopCount = 0;
        }
        else if(distance < 10){
            _stopCount += 1;
        }
        else{
            _lastPosition = _currentPosition;
        }

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
    void suddenStop(){
        if(_lastPosition.getSpeed() - _currentPosition.getSpeed() > _maxSpeedDifference){
            notify("quickStop");
        }
    }


    /*
     * Author: Gian Geyser
     * Parameters: String containing the type of notification
     * Returns: none
     * Description: Creates a notification based on the type parameter to notify
     *              the user of an abnormality occurring.
     */
    void notify(String type){
        if(type.equals("quickStop")){

        }
        else if(type.equals("offRoute")){

        }
        else if(type.equals("stoppingTooLong")){

        }
    }


    /*
     * Author: Gian Geyser
     * Parameters: Position object of the couriers current position.
     * Returns: none
     * Description: Sets the current position and last position if not set, then
     *              calls all the abnormality functions.
     */
    void checkAllAbnormalities(Location currentPosition){
        _currentPosition = currentPosition;
        if(_lastPosition == null){
            _lastPosition = currentPosition;
        }
        suddenStop();
        offRoute();
        stoppingTooLong();
    }
}
