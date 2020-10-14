import 'package:courier_driver_tracker/screens/home.dart';
import 'package:courier_driver_tracker/services/background/background_widget.dart';
import 'package:flutter/material.dart';
import 'package:courier_driver_tracker/routing.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await DotEnv().load('.env');
  runApp(CourierDriverTracker());
}

class CourierDriverTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: Router.generateRoute,
      home: BackgroundWidget(
        child: HomePage(),
      ),
    );
  }
}
