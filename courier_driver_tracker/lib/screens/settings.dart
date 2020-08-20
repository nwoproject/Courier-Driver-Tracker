import 'package:courier_driver_tracker/services/location/route_logging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "dart:ui";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final headingLabelStyle = TextStyle(
      fontSize: 25, fontFamily: 'OpenSans-Regular', color: Colors.grey[100]);
  final textStyle = TextStyle(
      fontSize: 20, fontFamily: 'OpenSans-Regular', color: Colors.grey[100]);
  final RouteLogging routeLogging = RouteLogging();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        bottomNavigationBar: _buildBottomNavigationBar,
        backgroundColor: Colors.grey[900],
        body: Container(
            child: Card(
                color: Colors.grey[800],
                elevation: 10,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                ))));
  }

  Widget get _buildBottomNavigationBar {
    return ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
        child: BottomNavigationBar(
            backgroundColor: Colors.grey[800],
            unselectedItemColor: Colors.grey[100],
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.home,
                    size: 30, color: Colors.grey[100]),
                title: SizedBox(
                  width: 0,
                  height: 0,
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.mapMarkerAlt,
                    size: 30, color: Colors.grey[100]),
                title: SizedBox(
                  width: 0,
                  height: 0,
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.userAlt,
                    size: 30, color: Colors.grey[100]),
                title: SizedBox(
                  width: 0,
                  height: 0,
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.cog, size: 30, color: Colors.blue),
                title: SizedBox(
                  width: 0,
                  height: 0,
                ),
              )
            ],
            onTap: (index) {
              if (index == 0) {
                Navigator.of(context).popAndPushNamed("/delivery");
              } else if (index == 1) {
                Navigator.of(context).pop();
              } else if (index == 2) {
                Navigator.of(context).popAndPushNamed("/profile");
              }
            }));
  }
}
