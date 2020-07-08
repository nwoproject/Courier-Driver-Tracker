import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:courier_driver_tracker/services/UniversalFunctions.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LocalNotifications(),
    );
  }
}

class LocalNotifications extends StatefulWidget {
  @override
  _LocalNotificationsState createState() => _LocalNotificationsState();
}

class _LocalNotificationsState extends State<LocalNotifications> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;

  @override
  void initState() {
    super.initState();
    initializing();
  }

  void initializing() async {
    androidInitializationSettings = AndroidInitializationSettings('app_icon');
    iosInitializationSettings = IOSInitializationSettings();
    initializationSettings = InitializationSettings(
        androidInitializationSettings, iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  void _showNotifications() async {
    await notification();
  }

  Future<void> notification() async {
    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
        'Channel ID', 'Channel title', 'channel body',
        priority: Priority.High,
        importance: Importance.Max,
        ticker: 'test');

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();

    NotificationDetails notificationDetails =
    NotificationDetails(androidNotificationDetails, iosNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0, 'Test', 'You have not moved in a while!', notificationDetails);
  }

  onSelectNotification(String payLoad) {
    if (payLoad != null) {
      print(payLoad);
    }
  }

  @override
  Widget build(BuildContext context) {
    Position position;
    Position position2 = Provider.of<Position>(context);
    const timeout = const Duration(seconds: 4);
    const ms = const Duration(milliseconds: 1);

    startTimeout([int milliseconds]) {
      var duration = milliseconds == null ? timeout : ms * milliseconds;

      return new Timer(duration, ()=>{
        if(isMoving(position, position2)){
          position = new Position(latitude: position2.latitude, longitude: position2.longitude)}
        else{
          _showNotifications()
        },
        startTimeout()
      });
    }

    if(position == null && position2 != null){
      position = Position(latitude: position2.latitude, longitude: position2.longitude);
      startTimeout();
    }

    return Container();
  }
}