import 'package:flutter/material.dart';
import 'package:courier_driver_tracker/routing.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await DotEnv().load('.env');
  runApp(CourierDriverTracker());
}

class CourierDriverTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      onGenerateRoute: Router.generateRoute,
    );
  }
}
