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
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import com.ctrlaltelite.courier_driver_tracker.location_service.Common;
import com.ctrlaltelite.courier_driver_tracker.location_service.SendLocationToActivity;
import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public class BackgroundService extends Service {

    private static final String channelID = "locationStream";
    private static final String EXTRA_STARTED_FROM_NOTIFICATION = "com.ctrlaltelite.courier_driver_tracker"
            + ".started_from_notification";

    private final IBinder binder = new LocalBinder();
    private static final long updateInterval = 5000;
    private static final long fastestUpdateInterval = updateInterval/2;
    private static final int notificationID = 24;
    private boolean changingConfiguration = false;
    private NotificationManager notificationManager;

    private LocationRequest locationRequest;
    private FusedLocationProviderClient fusedLocationProviderClient;
    private LocationCallback locationCallback;
    private Handler serviceHandler;
    public Location location;

    public BackgroundService(){

    }

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

    @Override
    public int onStartCommand(Intent intent, int flags, int startId){
        boolean startedFromNotification = intent.getBooleanExtra(EXTRA_STARTED_FROM_NOTIFICATION, false);
        if(startedFromNotification){
            removeLocationUpdates();
            stopSelf();
        }
        return START_NOT_STICKY;
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig){
        super.onConfigurationChanged(newConfig);
        changingConfiguration = true;
    }

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

    private void getLastLocation(){
        try{
            fusedLocationProviderClient.getLastLocation()
                    .addOnCompleteListener(
                        new OnCompleteListener<Location>(){
                        @Override
                        public void onComplete(@NonNull Task<Location> task) {
                            if(task.isSuccessful() && task.getResult() != null){
                                location = task.getResult();
                            }
                            else{
                                Log.e("CTRLALTELITE_DEV", "Failed to get location");
                            }
                        }
                    });
        }
        catch (SecurityException ex){
            Log.e("CTRLALTELITE_DEV", "Lost location permission." + ex);
        }
    }

    private void createLocationRequest(){
        locationRequest = new LocationRequest();
        locationRequest.setInterval(updateInterval);
        locationRequest.setFastestInterval(fastestUpdateInterval);
        locationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
    }

    private void onNewLocation(Location lastLocation){
        location = lastLocation;
        // EventBus.getDefault().postSticky(new SendLocationToActivity(location));

        //if running in foreground
        if(serviceIsRunningInForeGround(this)){
            notificationManager.notify(notificationID, getNotification());
        }
    }

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

    public class LocalBinder extends Binder {
        BackgroundService getService(){
            return BackgroundService.this;
        }
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        stopForeground(true);
        changingConfiguration = false;
        return binder;
    }

    @Override
    public void onRebind(Intent intent){
        stopForeground(true);
        changingConfiguration = false;
        super.onRebind(intent);
    }

    @Override
    public boolean onUnbind(Intent intent){
        if(!changingConfiguration && Common.requestingLocationUpdates(this)) {
            startForeground(notificationID, getNotification());
        }
        return true;
    }

    @Override
    public void onDestroy(){
        serviceHandler.removeCallbacks(null);
        super.onDestroy();
    }

}
