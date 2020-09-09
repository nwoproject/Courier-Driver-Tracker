import 'package:courier_driver_tracker/services/file_handling/route_logging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "dart:ui";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final headingLabelStyle = TextStyle(
      fontSize: 30, fontFamily: 'OpenSans-Regular', color: Colors.grey[200]);
  final textStyle = TextStyle(
      fontSize: 20, fontFamily: 'OpenSans-Regular', color: Colors.grey[100]);
  final avatarText = TextStyle(
      fontSize: 50, fontFamily: 'OpenSans-Regular', color: Colors.grey[100]);
  final labelStyle = TextStyle(
      fontSize: 25, fontFamily: 'OpenSans-Regular', color: Colors.grey[100]);
  final RouteLogging routeLogging = RouteLogging();

  final storage = new FlutterSecureStorage();
  var userData = {'name': 'name', 'surname': 'surname', 'email': 'email'};

  Future<Null> readUserData() async {
    var name = await storage.read(key: 'name');
    var surname = await storage.read(key: 'surname');
    var email = await storage.read(key: 'email');
    setState(() {
      return userData = {
        'name': name,
        'surname': surname,
        'email': email,
      };
    });
  }

  @override
  void initState() {
    readUserData();
    super.initState();
  }

  String get email {
    if (userData['email'] == null) {
      return "Error";
    } else {
      return userData['email'];
    }
  }

  String get name {
    if (userData['name'] == null ||
        userData['name'].length < 1 ||
        userData['surname'] == null ||
        userData['surname'].length < 1) {
      return "Error";
    } else {
      return userData['name'] + " " + userData['surname'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      bottomNavigationBar: _buildBottomNavigationBar,
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 7.0, top: 20.0),
                child: Container(
                    child: CircleAvatar(
                  radius: 125,
                  backgroundColor: Colors.blue.shade800,
                  child: Text(userData['name'][0] + userData['surname'][0],
                      style: avatarText),
                )),
              ),
            ),
            Expanded(
              flex: 1,
              child: ListView(
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ListTile(
                          title: Center(
                              child: Text(name, style: headingLabelStyle))))
                ],
              ),
            ),
            Expanded(
              flex: 6,
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: _profileCard(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: ListTile(
        subtitle: RichText(
            text: TextSpan(children: [
          WidgetSpan(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Divider(
                color: Colors.grey,
                thickness: 1,
                indent: 10,
                endIndent: 10,
              ),
            ),
          ),
          TextSpan(text: "Email \n", style: labelStyle),
          TextSpan(text: email + "\n\n\n", style: textStyle),
          TextSpan(text: "Driver Score:\n", style: labelStyle),
          TextSpan(text: "212\n\n\n", style: textStyle),
          TextSpan(text: "Routes Completed:\n", style: labelStyle),
          TextSpan(text: "12", style: textStyle)
        ])),
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
                    size: 30, color: Colors.blue),
                title: SizedBox(
                  width: 0,
                  height: 0,
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.cog,
                    size: 30, color: Colors.grey[100]),
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
              } else if (index == 3) {
                Navigator.of(context).popAndPushNamed("/settings");
              }
            }));
  }
}
