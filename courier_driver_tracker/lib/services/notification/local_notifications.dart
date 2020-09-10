import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class LocalNotifications {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;
  bool initialised = false;
  String report = "";
  BuildContext _notificationContext;

  void initializing(BuildContext context) async {
    setContext(context);
    androidInitializationSettings = AndroidInitializationSettings('ic_stat_name');
    iosInitializationSettings = IOSInitializationSettings();
    initializationSettings = InitializationSettings(
        androidInitializationSettings, iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    initialised = true;
  }

  void showNotifications(String header, String message) async {
    if(!initialised){
      print("Dev: Notification initialisation failed.");
      return;
    }
    await _notification(header, message);
  }

  Future<void> _notification(String header, String message) async {
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

  setContext(BuildContext context){
    _notificationContext = context;
  }

   Future onSelectNotification(String payLoad) async{
    if (payLoad != null) {
      print(payLoad);
    }

    if (report == "long") {
      await  Navigator.of(_notificationContext)
          .pushNamed('/reportLong');
    }
    if (report == "sudden") {
      await  Navigator.of(_notificationContext)
          .pushNamed('/reportSudden');
    }
    if (report == "speeding") {
      await  Navigator.of(_notificationContext)
          .pushNamed('/reportSpeed');
    }
//    if (report == "slow") {
//      await  Navigator.of(_notificationContext)
//          .pushNamed('/reportSpeed');
//    }
    if (report == "offRoute") {
      await  Navigator.of(_notificationContext)
          .pushNamed('/reportOff');
    }
  }

}
