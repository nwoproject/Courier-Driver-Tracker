import 'package:courier_driver_tracker/services/file_handling/route_logging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "dart:ui";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final headingLabelStyle = TextStyle(
      fontSize: 25, fontFamily: 'OpenSans-Regular', color: Colors.grey[100]);
  final textStyle = TextStyle(
      fontSize: 20, fontFamily: 'OpenSans-Regular', color: Colors.grey[100]);
  final subtitle = TextStyle(
      fontSize: 18, fontFamily: 'OpenSans-Regular', color: Colors.grey[500]);
  final RouteLogging routeLogging = RouteLogging();

  final storage = new FlutterSecureStorage();
  var userData = {'name': 'name', 'surname': 'surname'};

  Future<Null> readUserData() async {
    var name = await storage.read(key: 'name');
    var surname = await storage.read(key: 'surname');
    setState(() {
      return userData = {
        'name': name,
        'surname': surname,
      };
    });
  }

  @override
  void initState() {
    readUserData();
    super.initState();
  }

  void _logoutDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Are you sure you want to log out?"),
            content:
                Text("This App will no longer be able to track your driving."),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Accept'),
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/login'));
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNavigationBar,
      backgroundColor: Colors.grey[900],
      body: Theme(
        data: Theme.of(context).copyWith(
          brightness: Brightness.dark,
          primaryColor: Colors.grey,
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 30.0),
                Row(
                  children: <Widget>[
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Settings", style: headingLabelStyle),
                          Text(
                            "Driver",
                            style: TextStyle(
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                ListTile(
                  title: Text(
                    "Change Password",
                    style: textStyle,
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.grey.shade400,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('/changePassword');
                  },
                ),
                ListTile(
                  title: Text(
                    "Profile Settings",
                    style: textStyle,
                  ),
                  subtitle: Text(
                    userData['name'] + " " + userData['surname'],
                    style: subtitle,
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.grey.shade400,
                  ),
                  onTap: () {
                    Navigator.of(context).popAndPushNamed('/profile');
                  },
                ),
                ListTile(
                  title: Text(
                    "Logout",
                    style: textStyle,
                  ),
                  onTap: () => _logoutDialog(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
