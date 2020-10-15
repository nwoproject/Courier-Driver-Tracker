import 'package:courier_driver_tracker/services/file_handling/route_logging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "dart:ui";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:courier_driver_tracker/services/UniversalFunctions.dart';
import 'package:courier_driver_tracker/services/graph/blocs/home_page_bloc.dart';
import 'package:courier_driver_tracker/services/graph/radial_progress.dart';
import 'package:courier_driver_tracker/services/graph/show_graph.dart';
import 'package:courier_driver_tracker/services/api_handler/api.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  HomePageBloc _homePageBloc;
  AnimationController _iconAnimationController;
  final RouteLogging routeLogging = RouteLogging();

  List<Widget> _abnormalities = [];
  List<Widget> _abnormalitiesLoadingg = [];
  ApiHandler _api = ApiHandler();

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

    getAbnormalities();
    ShowGraph();
    _homePageBloc = HomePageBloc();
    _iconAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    super.initState();
  }

  getAbnormalities() async {
    List<dynamic> abnorm = await _api.getDriverAbnormalities();

    if (abnorm.length <= 0) {
      setState(() {
        _abnormalitiesLoadingg.add(Padding(
          padding: const EdgeInsets.all(2.0),
          child: _buildAbnorm(
            "assets/images/medal.png",
            "No abnormalities",
            "We are watching you",
            "",
          ),
        ));

        _abnormalities = _abnormalitiesLoadingg;
      });
    } else {
      for (int i = 0; i < abnorm.length; i++) {
        if (abnorm[i]['type'] == "abnormality") {
          //Abnormality
          String description = "";
          if (abnorm[i]['description'] == "Standing still for too long.") {
            description = "Standing still";
          }
          if (abnorm[i]['description'] == "Driver came to a sudden stop.") {
            description = "Sudden stop";
          }
          if (abnorm[i]['description'] == "Driver exceeded the speed limit.") {
            description = "Driving to fast";
          }
          if (abnorm[i]['description'] ==
              "Driver took a diffrent route than what was prescribed.") {
            description = "Off route";
          }
          if (abnorm[i]['description'] ==
              "Driver was driving with the company car when no deliveries were scheduled.") {
            description = "driving company car";
          }
          if (abnorm[i]['description'] ==
              "Driver never embarked on the route that was assigned to him.") {
            description = "Never started your route";
          }
          if (abnorm[i]['description'] ==
              "Driver skipped a delivery on his route.") {
            description = "Skipped a delivery";
          }
          if (abnorm[i]['description'] == "error") {
            description = "DataBase eror!";
          }
          setState(() {
            _abnormalitiesLoadingg.add(Padding(
              padding: const EdgeInsets.all(2.0),
              child: _buildAbnorm("assets/images/violation.png", "Violation",
                  description, abnorm[i]['datetime']),
            ));

            _abnormalities = _abnormalitiesLoadingg;
          });
        }
        if (abnorm[i]['type'] == "route_completion") {
          //Route completion
          setState(() {
            _abnormalitiesLoadingg.add(Padding(
              padding: const EdgeInsets.all(2.0),
              child: _buildAbnorm("assets/images/routeComplete.png",
                  "Route completed", "", abnorm[i]['datetime']),
            ));

            _abnormalities = _abnormalitiesLoadingg;
          });
        }

        if (abnorm[i]['type'] == "delivery") {
          //Route completion
          setState(() {
            _abnormalitiesLoadingg.add(Padding(
              padding: const EdgeInsets.all(2.0),
              child: _buildAbnorm(
                  "assets/images/deliveryComplete.png",
                  "Delivery completed",
                  abnorm[i]['name'],
                  abnorm[i]['datetime']),
            ));

            _abnormalities = _abnormalitiesLoadingg;
          });
        }
      }
    }
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
    SizeConfig().init(context);
    return new Scaffold(
      bottomNavigationBar: _buildBottomNavigationBar,
      backgroundColor: Colors.white,
      body: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            color: Colors.blue[600],
            height: 25 * SizeConfig.blockSizeVertical,
            child: Padding(
              padding: EdgeInsets.only(
                  left: 30.0,
                  right: 30.0,
                  top: 5 * SizeConfig.blockSizeVertical),
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
                                fontFamily: "Montserrat",
                                fontSize: 3 * SizeConfig.blockSizeVertical,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Driver",
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                color: Colors.white70,
                                fontSize: 2 * SizeConfig.blockSizeVertical),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20 * SizeConfig.blockSizeVertical),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30.0),
                      topLeft: Radius.circular(30.0))),
              child: ListView(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Profile",
                              style: TextStyle(
                                  fontFamily: "Montserrat",
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 4 * SizeConfig.blockSizeVertical),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 0.8,
                    color: Colors.grey,
                    indent: 20,
                    endIndent: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          "Statistics", //Deliveries made *mockdata*
                          style: TextStyle(
                              fontFamily: "Montserrat",
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 2.7 * SizeConfig.blockSizeVertical),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 35 * SizeConfig.blockSizeVertical,
                    child: Column(
                      children: <Widget>[
                        RadialProgress(),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            "Performance",
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                color: Colors.black,
                                fontSize: 2.5 * SizeConfig.blockSizeVertical),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 0.8,
                    color: Colors.grey,
                    indent: 20,
                    endIndent: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Column(children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            "Driving History", //Deliveries made *mockdata*
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 2.7 * SizeConfig.blockSizeVertical),
                          ),
                        ),
                      ]),
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                        padding: EdgeInsets.only(top: 5.0),
                        child:
                            Container(child: Column(children: _abnormalities))),
                  ),
                ],
              ),
            ),
          ),
        ],
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
            backgroundColor: Colors.black87,
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

  Widget _buildAbnorm(
      String imagePath, String type, String discription, String time) {
    return Padding(
        padding: EdgeInsets.only(right: 10.0, top: 10.0),
        child: InkWell(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Row(children: [
                      Hero(
                          tag: time,
                          child: Image(
                              image: AssetImage(imagePath),
                              fit: BoxFit.cover,
                              height: 100.0,
                              width: 100)),
                      SizedBox(width: 10.0),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(type,
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                softWrap: true),
                            Text(
                              "$discription\n$time",
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  color: Colors.grey),
                            ),
                          ])
                    ])),
              ],
            )));
  }
}
