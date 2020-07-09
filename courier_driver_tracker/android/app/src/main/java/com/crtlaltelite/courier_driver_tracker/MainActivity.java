package com.altctrlelite.courier_driver_tracker;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    private Intent forService;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(new FlutterEngine(this));

        forService = new Intent(MainActivity.this, MyService.class);

        new MethodChannel(Objects.requireNonNull(getFlutterEngine()).getDartExecutor(), "com.retroportalstudio.messages").setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(@NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {
                if(methodCall.method.equals("startService")){
                    startService();
                    result.success("service Started");
                }
            }
        });
    }

    private void startService(){
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            startForegroundService(forService);
        }else{
            startService(forService);
        }
    }
}
