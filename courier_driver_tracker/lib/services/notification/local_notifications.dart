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

  void initializing() async {
    androidInitializationSettings = AndroidInitializationSettings('ic_stat_name');
    iosInitializationSettings = IOSInitializationSettings();
    initializationSettings = InitializationSettings(
        androidInitializationSettings, iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings
        );
    initialised = true;
  }

  void showNotifications(String header, String message) async {
    if(!initialised){
      initializing();
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

  onSelectNotification(String payLoad) {
    if (payLoad != null) {
      print(payLoad);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
