import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:courier_driver_tracker/screens/login.dart';
import 'package:courier_driver_tracker/screens/home.dart';
import 'file:///D:/COS/COS301/CapstoneProject/Courier-Driver-Tracker/Courier-Driver-Tracker/courier_driver_tracker/lib/services/file_handling/route_logging.dart';


/*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: bool
   * Description: Checks if location service is enabled.
*/
Future<bool> isLocationServiceEnabled() async {
  return await Geolocator().isLocationServiceEnabled();
}


/*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: async
   * Description: Checks if always location permission is enabled.
*/
Future<bool> isLocationPermissionGranted() async {
  final GeolocationStatus geoPermission = await Geolocator()
      .checkGeolocationPermissionStatus(
      locationPermission: GeolocationPermission.locationAlways
      );
  if(geoPermission == GeolocationStatus.granted){
    return true;
  }
  else{
    return false;
  }
}

/*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: bool
   * Description: Requests to enable the location service.
*/
Future<bool> requestLocationService() async {
  final Location location = Location();
  bool _serviceEnabled;
  print("error checking");
  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    print("requesting");
    _serviceEnabled = await location.requestService();
    print("requested");
    print(_serviceEnabled);
  }
  print("returning");
  return _serviceEnabled;
}

/*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: bool
   * Description: Requests location permissions.
   */
Future<bool> requestLocationPermission() async {
  final Geolocator geolocator = Geolocator();
  await geolocator.getCurrentPosition();
  GeolocationStatus geoPermission = await geolocator
      .checkGeolocationPermissionStatus(
      locationPermission: GeolocationPermission.locationAlways
  );
  if(geoPermission == GeolocationStatus.granted){
    return true;
  }
  else{
    return false;
  }
}

/*
   * Author: Gian Geyser
   * Description: Creates a dialog widget which explains all the permissions required by the application.
   */
Future<void> showMyDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Setup'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              RichText(
                text: TextSpan(
                  text: 'Courier Tracker is an application that makes use of your devices ',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[800],
                  ),
                  children: <TextSpan>[
                    TextSpan(text: 'Location Services', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: '. Make sure your Location Services is '),
                    TextSpan(text: 'Enabled.', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              RichText(
                text: TextSpan(
                  text: 'Courier Tracker also runs in the background and requires the location permission ',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[800],
                  ),
                  children: <TextSpan>[
                    TextSpan(text: 'Always', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' to be '),
                    TextSpan(text: 'Enabled.', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Continue'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

/*
   * Author: Gian Geyser
   * Description: Widget displaying a list of all permissions needed by the application with explanations why.
   */
class Permissions extends StatefulWidget {
  @override
  _PermissionsState createState() => _PermissionsState();
}

class _PermissionsState extends State<Permissions> {
  static bool servicesEnabled = false;
  static bool locationPermissionGiven = false;
  static bool writePermissionGiven = false;

  @override
  void initState(){
    super.initState();
    checkPermissionsAndServices();
  }

  checkPermissionsAndServices() async {
    bool serv = await isLocationServiceEnabled();
    bool locPerm = await isLocationPermissionGranted();
    bool storagePerm = await RouteLogging.checkPermissions();
    setState(() {
      servicesEnabled = serv;
      locationPermissionGiven = locPerm;
      writePermissionGiven = storagePerm;
    });
  }

  request() async {
    bool loggedIn = false;
    if(!servicesEnabled){
      bool success = false;
      print("getting Service");
      success = await requestLocationService();
      print(success);
      if(success){
        setState(() {
          servicesEnabled = true;
        });
      }
    }
    if(!locationPermissionGiven){
      bool success = await requestLocationPermission();
      if(success){
        setState(() {
          locationPermissionGiven = true;
        });
      }
    }
    if(!writePermissionGiven){
      bool success = await RouteLogging.getPermissions();
      if(success){
        setState(() {
          locationPermissionGiven = true;
        });
      }
    }
    if(servicesEnabled && locationPermissionGiven){
      if(loggedIn){
        _navigateToHome();
      }
      else{
        _navigateToLogin();
      }
    }
  }

  void _navigateToLogin(){
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (BuildContext context) => LoginPage()
        )
    );
  }

  void _navigateToHome(){
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (BuildContext context) => HomePage()
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 30.0, left: 25.0),
                  child: Text(
                    "SETUP",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                    ),
                  ),
                ),
                Divider(
                  height: 60.0,
                  color: Colors.white,
                  thickness: 2.0,
                  indent: 10.0,
                  endIndent: 10.0,
                ),
                Expanded(
                  flex: 1,
                  child: ListView(
                        children: <Widget>[
                          Card(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListTile(
                                      title: Padding(
                                        padding: const EdgeInsets.only(bottom: 10.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "Location Services",
                                              style: TextStyle(
                                                fontSize: 20.0,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Divider(
                                              height: 20.0,
                                              thickness: 3.0,
                                              color: servicesEnabled ?
                                                  Colors.green:
                                                  Colors.red,
                                            ),
                                          ],
                                        ),
                                      ),
                                      subtitle: RichText(
                                        text: TextSpan(
                                          text: 'This application uses the devices\' GPS to track the current location. Enable the ',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey[800],
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(text: 'location services', style: TextStyle(fontWeight: FontWeight.bold)),
                                            TextSpan(text: ' to use the application.'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: OutlineButton(
                                      child: Text(
                                        servicesEnabled ?
                                        "ENABLED" :
                                        "ENABLE",
                                        style: TextStyle(
                                          color: servicesEnabled ?
                                          Colors.green :
                                          Colors.blue,
                                        ),
                                      ),
                                      onPressed: request,
                                    ),
                                  ),
                                ]),
                          ),
                          Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    title: Padding(
                                      padding: const EdgeInsets.only(bottom: 10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "Location Permission",
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Divider(
                                            height: 20.0,
                                            thickness: 3.0,
                                            color: locationPermissionGiven ?
                                            Colors.green:
                                            Colors.red,
                                          ),
                                        ],
                                      ),
                                    ),
                                    subtitle: RichText(
                                      text: TextSpan(
                                        text: 'This application runs as a background service. Please select ',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey[800],
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(text: 'Always', style: TextStyle(fontWeight: FontWeight.bold)),
                                          TextSpan(text: ' when asked for location permissions to use the application.'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: OutlineButton(
                                    highlightedBorderColor: Colors.green,
                                    splashColor: Colors.green,
                                    child: Text(
                                      locationPermissionGiven ?
                                      "ENABLED" :
                                      "ENABLE",
                                      style: TextStyle(
                                        color: locationPermissionGiven ?
                                        Colors.green :
                                        Colors.blue,
                                      ),
                                    ),
                                    onPressed: request,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    title: Padding(
                                      padding: const EdgeInsets.only(bottom: 10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "Location Permission",
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Divider(
                                            height: 20.0,
                                            thickness: 3.0,
                                            color: writePermissionGiven ?
                                            Colors.green:
                                            Colors.red,
                                          ),
                                        ],
                                      ),
                                    ),
                                    subtitle: RichText(
                                      text: TextSpan(
                                        text: 'This application runs as a background service. Please select ',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey[800],
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(text: 'Always', style: TextStyle(fontWeight: FontWeight.bold)),
                                          TextSpan(text: ' when asked for location permissions to use the application.'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: OutlineButton(
                                    highlightedBorderColor: Colors.green,
                                    splashColor: Colors.green,
                                    child: Text(
                                      writePermissionGiven ?
                                      "ENABLED" :
                                      "ENABLE",
                                      style: TextStyle(
                                        color: writePermissionGiven ?
                                        Colors.green :
                                        Colors.blue,
                                      ),
                                    ),
                                    onPressed: request,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                ),
              ]
          ),
      ),
    );
  }
}
