package com.ctrlaltelite.courier_driver_tracker.location_service;

import android.content.Context;
import android.location.Location;
import android.preference.PreferenceManager;

import com.ctrlaltelite.courier_driver_tracker.BackgroundService;

import java.text.DateFormat;
import java.util.Date;

public class Common {

    public static final String KEY_REQUESTING_LOCATION_UPDATES = "LocationUpdateEnable";

    public  static String getLocationText(Location location) {
        return location == null ? "Unknown" : new StringBuilder()
                .append(location.getLatitude())
                .append("/")
                .append(location.getLongitude())
                .toString();
    }
    public static CharSequence getLocationTitle(BackgroundService backgroundService){
        return String.format("Location Updated : %1$s", DateFormat.getDateInstance().format(new Date()));
    }

    public static void setRequestingLocationUpdates(Context context, boolean value){
        PreferenceManager.getDefaultSharedPreferences(context)
                .edit()
                .putBoolean(KEY_REQUESTING_LOCATION_UPDATES, value)
                .apply();
    }

    public static boolean requestingLocationUpdates(Context context){
        return PreferenceManager.getDefaultSharedPreferences(context)
                .getBoolean(KEY_REQUESTING_LOCATION_UPDATES, false);
    }
}