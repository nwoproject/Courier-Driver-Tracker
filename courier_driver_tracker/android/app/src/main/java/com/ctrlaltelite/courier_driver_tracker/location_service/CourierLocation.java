package com.ctrlaltelite.courier_driver_tracker.location_service;

public enum CourierLocation {
    latitude, // Latitude, in degrees
    longitude, // Longitude, in degrees
    accuracy, // Estimated horizontal accuracy of this location, radial, in meters
    altitude, // In meters above the WGS 84 reference ellipsoid
    speed, // In meters/second
    heading, //Heading is the horizontal direction of travel of this device, in degrees
    time //timestamp of the LocationData
}
