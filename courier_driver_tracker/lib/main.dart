import 'package:flutter/material.dart';
import 'package:courier_driver_tracker/routing.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screen/screen.dart';

Future main() async {
  await DotEnv().load('.env');
  Screen.keepOn(true);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  .then((_) {
    runApp(CourierDriverTracker());
  });
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
