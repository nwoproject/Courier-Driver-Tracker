import 'package:courier_driver_tracker/services/location/route_logging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "dart:ui";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:courier_driver_tracker/services/UniversalFunctions.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      return "Did not recieve email";
    } else {
      return userData['email'];
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return new Scaffold(
      bottomNavigationBar: _buildBottomNavigationBar,
      backgroundColor: Colors.white,
      body: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            color: Colors.blue[600],
            height: 40 * SizeConfig.blockSizeVertical,
            child: Padding(
              padding: EdgeInsets.only(
                  left: 30.0,
                  right: 30.0,
                  top: 10 * SizeConfig.blockSizeVertical),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        height: 11 * SizeConfig.blockSizeVertical,
                        width: 22 * SizeConfig.blockSizeHorizontal,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image:
                                    AssetImage("assets/images/profile.png"))),
                      ),
                      SizedBox(
                        width: 5 * SizeConfig.blockSizeHorizontal,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            userData['name'] + " " + userData['surname'],
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 3 * SizeConfig.blockSizeVertical,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Driver",
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 2 * SizeConfig.blockSizeVertical),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 3 * SizeConfig.blockSizeVertical),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            "120", //Deliveries made *mockdata*
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 3 * SizeConfig.blockSizeVertical,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Deliveries Made",
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 2 * SizeConfig.blockSizeVertical),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            "520", //Driver score *mockdata*
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 3 * SizeConfig.blockSizeVertical,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "score",
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 2 * SizeConfig.blockSizeVertical),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Container(
                            width: 10 * SizeConfig.blockSizeVertical,
                          )
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(top: 35 * SizeConfig.blockSizeVertical),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30.0),
                        topLeft: Radius.circular(30.0))),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            left: 30.0, top: 3 * SizeConfig.blockSizeVertical),
                        child: Text(
                          "Recent Deliveries",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 2.5 * SizeConfig.blockSizeVertical),
                        ),
                      ),
                      SizedBox(
                        height: 3 * SizeConfig.blockSizeVertical,
                      ),
                      Container(
                        height: 35 * SizeConfig.blockSizeVertical,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[],
                        ),
                      )
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }

  _route(delivery, location, time) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0),
      child: Container(
        height: 37 * SizeConfig.blockSizeVertical,
        width: 60 * SizeConfig.blockSizeHorizontal,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.grey, width: 0.2)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            color: Colors.grey,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 7.0, left: 7.0, right: 7.0),
                                  child: Text(
                                    "Delivery 1",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        top: 7.0, left: 7.0, right: 7.0),
                                    child: Text("Pretoria Boys HighSchool 1")),
                                Text("14:35")
                              ],
                            ),
                          ),
                        ],
                      )),
                ],
              ),
              SizedBox(
                height: 1 * SizeConfig.blockSizeVertical,
              ),
              Row(
                children: <Widget>[
                  ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            color: Colors.grey,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 7.0, left: 7.0, right: 7.0),
                                  child: Text(
                                    "Delivery 1",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        top: 7.0, left: 7.0, right: 7.0),
                                    child: Text("Pretoria Boys HighSchool 1")),
                                Text("14:35")
                              ],
                            ),
                          ),
                        ],
                      )),
                  Spacer(),
                ],
              ),
              SizedBox(
                height: 1 * SizeConfig.blockSizeVertical,
              ),
              Row(
                children: <Widget>[
                  ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            color: Colors.grey,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 7.0, left: 7.0, right: 7.0),
                                  child: Text(
                                    "Delivery 1",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        top: 7.0, left: 7.0, right: 7.0),
                                    child: Text("Pretoria Boys HighSchool 1")),
                                Text("14:35")
                              ],
                            ),
                          ),
                        ],
                      )),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: 10.0, top: 2 * SizeConfig.blockSizeVertical),
                child: Text(
                  "Route 1",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 2 * SizeConfig.blockSizeVertical,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
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
