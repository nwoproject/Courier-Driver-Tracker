import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:courier_driver_tracker/services/location/geolocator_service.dart';
import 'package:courier_driver_tracker/services/location/google_maps.dart';
import "dart:io" show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final geolocationService = GeolocatorService();
  @override
  Widget build(BuildContext context) {
    return StreamProvider<Position>(
      create: (context) => geolocationService.locationStream,
      child: HomePageView(),
    );
  }
}

class HomePageView extends StatefulWidget {
  @override
  _HomePageViewState createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  final storage = new FlutterSecureStorage();
  var userData = {'name': 'name', 'surname': 'surname'};
  int _currentIndex = 1;

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
    print("hello we creating home");
    readUserData();
    super.initState();
    startServiceInPlatform();
  }

  void startServiceInPlatform() async {
    if (Platform.isAndroid) {
      var methodChannel = MethodChannel("com.ctrlaltelite.messages");
      String data = await methodChannel.invokeMethod("startService");
      print(data);
    }
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(width: 2.5),
      borderRadius: BorderRadius.all(
          Radius.circular(30) //         <--- border radius here
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

    final headingLabelStyle = TextStyle(
      fontSize: 20,
      fontFamily: 'OpenSans-Regular',
    );

    Widget _deliveryCards(String text, String date) {
      return Card(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: ListTile(
            title: Text(
              text,
              style: headingLabelStyle,
            ),
            subtitle: Text(
              date,
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: _buildBottomNavigationBar,
        body: SlidingUpPanel(
          color: Color.fromARGB(255, 58, 52, 64),
          panel: Center(
            child: Container(
              padding: EdgeInsets.all(10),
              child: ListView(
                padding: const EdgeInsets.all(5),
                children: <Widget>[
                  _deliveryCards("Menlyn Park Shopping Centre",
                      "01-25-2020 12:00"), //mock data
                  _deliveryCards(
                      "Aroma Gourmet Coffee Roastery", "01-25-2020 13:00"),
                  _deliveryCards("University of Pretoria", "01-25-2020 13:45"),
                  _deliveryCards(
                      "Pretoria High School for boys", "01-25-2020 14:00"),
                ],
              ),
            ),
          ),
          collapsed: Container(
            decoration:
                BoxDecoration(color: Colors.white, borderRadius: radius),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, left: 10.0, right: 10),
                        child: Center(
                          child: Text('39 min',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontFamily: "OpenSans-Regular",
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, left: 10.0, right: 10),
                        child: Center(
                          child: Text("41km . 13:28",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: "OpenSans-Regular",
                                  fontSize: 20.0)),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: VerticalDivider(
                      width: 10.0,
                      color: Colors.grey,
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, left: 15.0),
                        child: Center(
                          child: Text('Delivery 1',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "OpenSans-Regular",
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, left: 15.0),
                        child: Center(
                          child: Text("Pretoria Boys High",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: "OpenSans-Regular",
                                  fontSize: 20.0)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: Expanded(child: GMap()),
          borderRadius: radius,
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
            currentIndex: _currentIndex,
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
                    size: 30, color: Colors.blue),
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
                Navigator.of(context).pushNamed("/delivery");
              } else if (index == 1) {
                Navigator.of(context).pushNamed("/home2");
              } else if (index == 2) {
                Navigator.of(context).pushNamed("/profile");
              } else if (index == 3) {
                Navigator.of(context).pushNamed("/settings");
              }
            }));
  }
}
