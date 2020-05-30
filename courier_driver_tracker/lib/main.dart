import 'package:flutter/material.dart';
import 'package:courier_driver_tracker/routing.dart';


void main() {
  runApp(CourierDriverTracker());
}

class CourierDriverTracker extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      onGenerateRoute: Router.generateRoute,
    );
  }
}