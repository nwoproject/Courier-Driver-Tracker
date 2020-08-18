package com.ctrlaltelite.courier_driver_tracker;

import com.ctrlaltelite.courier_driver_tracker.location_service.*;

import android.app.ActivityManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.location.Location;
import android.os.Binder;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.Looper;
import android.util.Log;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;


public class BackgroundService extends Service {
    /*
     * Author: Gian Geyser & Jordan Nijs
     * Description: Service that retrieves the users location while the application
     *              is minimized or closed while the user is still driving on his route.
     */

    private static final String channelID = "locationStream";               // ID of channel
    private static final String EXTRA_STARTED_FROM_NOTIFICATION =           // channel name
            "com.ctrlaltelite.courier_driver_tracker.started_from_notification";
    private final IBinder binder = new LocalBinder();                       // service binder
    private static final long updateInterval = 5000;                        // max update interval in milli seconds
    private static final long fastestUpdateInterval = updateInterval/2;     // min update interval in milli seconds
    private static final int notificationID = 24;                           // ID of notification channel
    private boolean changingConfiguration = false;                          // bool stating if application is moving between foreground and background
    private NotificationManager notificationManager;                        // a notification manager
    private LocationRequest locationRequest;                                // stores location retrieval options
    private FusedLocationProviderClient fusedLocationProviderClient;        // location client
    private LocationCallback locationCallback;                              // callback function for the location request
    private Handler serviceHandler;                                         // a service handler
    public Location location;                                               // current location of the courier


    /*
     * Author: Jordan Nijs
     * Parameters: none
     * Returns: none
     * Description: Default constructor for service.
     */
    public BackgroundService(){

    }

    /*
     * Author: Jordan Nijs
     * Parameters: none
     * Returns: none
     * Description: Overrides the super create function to initialize all the necessary variables
     *              required by the service.
     */
    @Override
    public void onCreate() {
        super.onCreate();

       fusedLocationProviderClient = LocationServices.getFusedLocationProviderClient(this);
       locationCallback = new LocationCallback() {
           @Override
           public void onLocationResult(LocationResult locationResult){
               super.onLocationResult(locationResult);
               onNewLocation(locationResult.getLastLocation());
           }
       };

       createLocationRequest();
       getLastLocation();

       HandlerThread handlerThread = new HandlerThread("CTRLALTELITE");
       handlerThread.start();
       serviceHandler = new Handler(handlerThread.getLooper());
       notificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);

       if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            NotificationChannel notificationChannel = new NotificationChannel(channelID,
                    getString(R.string.app_name),
                    NotificationManager.IMPORTANCE_DEFAULT);
            notificationManager.createNotificationChannel(notificationChannel);
       }

    }


    /*
     * Author: Jordan Nijs
     * Parameters: Intent intent, int flags, int startId
     * Returns: int
     * Description: Overrides the onStartCommand, when application is started from the background
     *              notification it stops the background service.
     */
    @Override
    public int onStartCommand(Intent intent, int flags, int startId){
        boolean startedFromNotification = intent.getBooleanExtra(EXTRA_STARTED_FROM_NOTIFICATION, false);
        if(startedFromNotification){
            removeLocationUpdates();
            stopSelf();
        }
        return START_NOT_STICKY;
    }


    /*
     * Author: Gian Geyser & Jordan Nijs
     * Parameters: none
     * Returns: Configuration
     * Description: Overrides the onConfigurationChanged, only sets the changingConfiguration to true.
     */
    @Override
    public void onConfigurationChanged(Configuration newConfig){
        super.onConfigurationChanged(newConfig);
        changingConfiguration = true;
    }


    /*
     * Author: Gian Geyser
     * Parameters: none
     * Returns: none
     * Description: Starts background service and makes location requests repeatedly with a looper function.
     */
    public void requestLocationUpdates(){
        Common.setRequestingLocationUpdates(this, true);
        startService(new Intent(getApplicationContext(), BackgroundService.class));
        try{
            fusedLocationProviderClient.requestLocationUpdates(locationRequest, locationCallback, Looper.myLooper());
        }
        catch (SecurityException ex){
            Log.e("CTRLALTELITE_Dev", "Lost location permission. Could not request it " + ex);
        }
    }


    /*
     * Author: Jordan Nijs
     * Parameters: none
     * Returns: none
     * Description: Stops requesting location updates and ends background service.
     */
    public void removeLocationUpdates(){
        try{
            fusedLocationProviderClient.removeLocationUpdates(locationCallback);
            Common.setRequestingLocationUpdates(this, false);
            stopSelf();
        }
        catch(SecurityException ex){
            Common.setRequestingLocationUpdates(this, true);
            Log.e("CTRLALTELITE_Dev", "Lost location permission. Could not remove updates. " + ex);
        }
    }


    /*
     * Author: Gian Geyser
     * Parameters: none
     * Returns: none
     * Description: Tries to retrieve the last known location of the courier.
     */
    private void getLastLocation(){
        try{
            fusedLocationProviderClient.getLastLocation()
                    .addOnCompleteListener(
                            task -> {
                                if(task.isSuccessful() && task.getResult() != null){
                                    location = task.getResult();
                                }
                                else{
                                    Log.e("CTRLALTELITE_DEV", "Failed to get location");
                                }
                            });
        }
        catch (SecurityException ex){
            Log.e("CTRLALTELITE_DEV", "Lost location permission." + ex);
        }
    }


    /*
     * Author: Gian Geyser
     * Parameters: none
     * Returns: none
     * Description: Sets the location request options.
     */
    private void createLocationRequest(){
        locationRequest = new LocationRequest();
        locationRequest.setInterval(updateInterval);
        locationRequest.setFastestInterval(fastestUpdateInterval);
        locationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
    }


    /*
     * Author: Gian Geyser
     * Parameters: Location of the courier
     * Returns: none
     * Description: When a new location is retrieved it updates the location variable.
     */
    private void onNewLocation(Location currentlocation){
        location = currentlocation;

        /*
        //if running in foreground
        if(serviceIsRunningInForeGround(this)){
            notificationManager.notify(notificationID, getNotification());
        }

         */
    }


    /*
     * Author: Gian Geyser
     * Parameters: Location object
     * Returns: String
     * Description: Takes a location object and creates a string from all the object variables.
     */
    private String locationToString(Location location){
        String values = "";
        values += location.getLatitude();
        values += "," + location.getLongitude();
        values += "," + location.getAccuracy();
        values += "," + location.getAltitude();
        values += "," + location.getSpeed();
        values += "," + location.getBearing();
        values += "," + location.getTime();

        return values;
    }


    /*
     * Author: Jordan Nijs
     * Parameters: none
     * Returns: Notification
     * Description: Uses the current position and last position to determine
     *              the distance traveled. Creates a notification if the position
     *              has not sufficiently moved within the specified
     *              cycles(_maxStopCount).
     */
    private Notification getNotification(){
        Intent intent = new Intent(this, BackgroundService.class);
        String title = "Courier Tracker";
        String message = "Application is running in the background.";



        intent.putExtra(EXTRA_STARTED_FROM_NOTIFICATION, true);
        PendingIntent servicePendingIntent = PendingIntent.getService(this, 0,intent,
                PendingIntent.FLAG_UPDATE_CURRENT);
        PendingIntent activityPendingIntent = PendingIntent.getActivity(this, 0,
                new Intent(this, MainActivity.class), 0);

        NotificationCompat.Builder builder = new NotificationCompat.Builder(this)
                .addAction(R.drawable.ic_baseline_launch_24, "Launch", activityPendingIntent)
                .addAction(R.drawable.ic_baseline_cancel_24,"Remove",servicePendingIntent)
                .setContentText(message)
                .setContentTitle(title)
                .setOngoing(true)
                .setPriority(Notification.PRIORITY_HIGH)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setTicker(message)
                .setWhen(System.currentTimeMillis());


        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            builder.setChannelId(channelID);
        }
        return builder.build();
    }


    /*
     * Author: Jordan Nijs
     * Parameters: Context
     * Returns: Boolean
     * Description: Checks if application is running in the foreground.
     */
    private boolean serviceIsRunningInForeGround(Context context){
        ActivityManager manager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        for(ActivityManager.RunningServiceInfo service : manager.getRunningServices(Integer.MAX_VALUE)){
            if(getClass().getName().equals(service.service.getClassName())){
                if(service.foreground){
                    return true;
                }
            }
        }
        return false;
    }


    /*
     * Author: Jordan Nijs
     * Description: Local wrapper class for background service binder
     */
    public class LocalBinder extends Binder {
        BackgroundService getService(){
            return BackgroundService.this;
        }
    }


    /*
     * Author: Jordan Nijs
     * Parameters: Intent
     * Returns: IBinder
     * Description: Overrides binders onBind function, removes background notification.
     */
    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        stopForeground(true);
        changingConfiguration = false;
        return binder;
    }


    /*
     * Author: Jordan Nijs
     * Parameters: Intent
     * Returns: none
     * Description: Overrides binders onRebind function, removes background notification.
     */
    @Override
    public void onRebind(Intent intent){
        stopForeground(true);
        changingConfiguration = false;
        super.onRebind(intent);
    }


    /*
     * Author: Jordan Nijs
     * Parameters: Intent
     * Returns: boolean
     * Description: Overrides binders onUnbind function, creates background notification.
     */
    @Override
    public boolean onUnbind(Intent intent){
        if(!changingConfiguration && Common.requestingLocationUpdates(this)) {
            startForeground(notificationID, getNotification());
        }
        return true;
    }


    /*
     * Author: Jordan Nijs
     * Parameters: none
     * Returns: none
     * Description: Overrides binders onDestroy function, removes callback functions.
     */
    @Override
    public void onDestroy(){
        serviceHandler.removeCallbacks(null);
        super.onDestroy();
    }

}
