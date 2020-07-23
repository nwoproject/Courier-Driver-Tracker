package com.ctrlaltelite.courier_driver_tracker;
import com.ctrlaltelite.courier_driver_tracker.location_service.*;
import com.karumi.dexter.Dexter;
import com.karumi.dexter.MultiplePermissionsReport;
import com.karumi.dexter.PermissionToken;
import com.karumi.dexter.listener.PermissionRequest;
import com.karumi.dexter.listener.multi.MultiplePermissionsListener;

import android.Manifest;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.preference.PreferenceManager;
import android.widget.Toast;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.Arrays;
import java.util.List;

import io.flutter.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity implements SharedPreferences.OnSharedPreferenceChangeListener {

    //new vars
    BackgroundService backgroundService = null;
    boolean bound = false;

    private final ServiceConnection serviceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName componentName, IBinder iBinder) {
            BackgroundService.LocalBinder binder = (BackgroundService.LocalBinder) iBinder;
            backgroundService = binder.getService();
            bound = true;
        }

        @Override
        public void onServiceDisconnected(ComponentName componentName) {
            backgroundService = null;
            bound = false;
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        System.out.println("Createing MainActivity");
        GeneratedPluginRegistrant.registerWith(this);

        //forService = new Intent(MainActivity.this, BackgroundService.class);
        Dexter.withActivity(MainActivity.this)
                .withPermissions(Arrays.asList(
                        Manifest.permission.ACCESS_FINE_LOCATION,
                        Manifest.permission.ACCESS_BACKGROUND_LOCATION
                ));

        bindService(new Intent( MainActivity.this,
                        BackgroundService.class),
                serviceConnection,
                Context.BIND_AUTO_CREATE);


        new MethodChannel(getFlutterView(), "com.ctrlaltelite.messages").setMethodCallHandler(
        new MethodChannel.MethodCallHandler()
        {
            @Override
            public void onMethodCall(MethodCall methodCall, MethodChannel.Result result){
                if(methodCall.method.equals("startService")){
                    //startService();
                    backgroundService.requestLocationUpdates();
                    result.success("Service started");
                }
            }
        });
    }

    //new

    @Override
    protected void onStart(){
        super.onStart();
        PreferenceManager.getDefaultSharedPreferences(this)
                .registerOnSharedPreferenceChangeListener(this);
        EventBus.getDefault().register(this);
    }

    @Override
    protected void onStop(){
        if(bound){
            unbindService(serviceConnection);
            bound = false;
        }
        PreferenceManager.getDefaultSharedPreferences(this)
                .unregisterOnSharedPreferenceChangeListener(this);
        super.onStop();
    }


    @Override
    public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String s) {
        if(s.equals(Common.KEY_REQUESTING_LOCATION_UPDATES)){
            // he set weird button states
            System.out.println("Mmmmmm, how you turn it off?");
        }
    }

    @Subscribe(sticky = true, threadMode = ThreadMode.MAIN)
    public void onListenLocation(SendLocationToActivity event){
    }
}
