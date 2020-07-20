package com.ctrlaltelite.courier_driver_tracker.location_service;

import android.location.Location;

public class SendLocationToActivity{
    private Location location;

    public SendLocationToActivity(Location location){
        this.location = location;
    }

    public Location getLocation() {
        return location;
    }

    public void setLocation(Location location) {
        this.location = location;
    }
}