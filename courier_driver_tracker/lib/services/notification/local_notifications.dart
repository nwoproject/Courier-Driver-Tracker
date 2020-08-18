import 'dart:async';
import 'package:courier_driver_tracker/services/Abnormality/abnormality_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
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
  Position _currentPosition;

  //Abnormality service
  AbnormalityService _abnormalityService = AbnormalityService();

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
    await flutterLocalNotificationsPlugin.initialize(initializationSettings
        );
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  void _showNotifications(String header, String message) async {
    await notification(header, message);
  }

  Future<void> notification(String header, String message) async {
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
        0, header, message, notificationDetails);
  }

   Future onSelectNotification(String payLoad) async{

    print("THIS IS THE PAYLOAD:::::::::::::::::::::::::::::::::::::::::::::" + payLoad);
    if (payLoad != null) {
      print(payLoad);
    await  Navigator.of(context)
        .pushNamed('/report');
    }

  }

  @override
  Widget build(BuildContext context) {
    _currentPosition = Provider.of<Position>(context);

    // Calls abnormality service
    if(_currentPosition != null){
      _abnormalityService.setCurrentLocation(_currentPosition);
      if(_abnormalityService.suddenStop()){
        _showNotifications("Warning", "You stopped very quickly!");
      }
      if(_abnormalityService.stoppingTooLong()){
          _showNotifications("Warning", "You haven't moved in a while!");
      }
    }

    return Container();
  }
}
