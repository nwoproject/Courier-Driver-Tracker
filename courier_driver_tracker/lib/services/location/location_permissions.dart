import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:courier_driver_tracker/screens/login.dart';
import 'package:courier_driver_tracker/screens/home.dart';

Future<bool> isLocationServiceEnabled() async {
  return await Geolocator().isLocationServiceEnabled();
}

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


class PermissionsStepper extends StatefulWidget {
  @override
  _PermissionsStepperState createState() => _PermissionsStepperState();
}

class _PermissionsStepperState extends State<PermissionsStepper> {
  static bool servicesEnabled = false;
  static bool permissionGiven = false;

  checkPermissionsAndServices() async {
    bool serv = await isLocationServiceEnabled();
    bool perm = await isLocationPermissionGranted();
    setState(() {
      servicesEnabled = serv;
      permissionGiven = perm;
    });
  }

  @override
  void initState(){
    super.initState();
    checkPermissionsAndServices();
  }

  int currentStep = 0;
  List<Step> steps;

  next(){
    currentStep + 1 != steps.length
        ? goTo(currentStep + 1)
        : setState(() => currentStep = 0);
  }

  request() async {
    bool loggedIn = false;
    if(currentStep == 0 && !servicesEnabled){
      bool success = await requestLocationService();
      if(success){
        setState(() {
          servicesEnabled = true;
        });
      }
    }
    else if(currentStep == 1 && !permissionGiven){
      bool success = await requestLocationPermission();
      if(success){
        setState(() {
          permissionGiven = true;
        });
      }
    }
    if(servicesEnabled && permissionGiven){
      if(loggedIn){
        _navigateToHome();
      }
      else{
        _navigateToLogin();
      }
    }
  }

  goTo(int step){
    setState(() => currentStep = step);
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

    steps = [
      Step(
        title: const Text(
          'LOCATION SERVICES',
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.black,
          ),
        ),
        state: servicesEnabled ? StepState.complete : StepState.error,
        content: Column(
          children: <Widget>[

          ],
        ),
      ),
      Step(
        title: const Text(
          'LOCATION PERMISSION',
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.black,
          ),
        ),
        state: permissionGiven == true ? StepState.complete : StepState.error,
        content: RichText(
          text: TextSpan(
            text: 'This application runs as a background service. Please select',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey[800],
            ),
            children: <TextSpan>[
              TextSpan(text: ' Always', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' when asked for location permissions to use the application.'),
            ],
          ),
        ),
      )
    ];


    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          'PERMISSIONS',
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.black,
          ),
        ),
        Text(
          'All the below permissions and services need to be enabled to use this application.',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[800],
          ),
        ),
        Expanded(
          child: Stepper(
            steps: steps,
            currentStep: currentStep,
            controlsBuilder: (BuildContext context,
                {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
              return Row(
                children: <Widget>[
                  FlatButton(
                    onPressed: onStepContinue,
                    child: Text(
                      currentStep == 0 ?
                      servicesEnabled == true
                          ? 'NEXT'
                          : 'SKIP' :
                      permissionGiven == true
                          ? 'NEXT'
                          : 'SKIP',
                    ),
                  ),
                  FlatButton(
                    child: Text(
                      currentStep == 0 ?
                      servicesEnabled == true
                          ? 'ENABLED'
                          : 'ENABLE' :
                      permissionGiven == true
                          ? 'ENABLED'
                          : 'ENABLE',
                      style: TextStyle(
                        color: currentStep == 0 ?
                        servicesEnabled == true
                            ? Colors.green
                            : Colors.blue :
                        permissionGiven == true
                            ? Colors.green
                            : Colors.blue,
                      ),
                    ),
                    onPressed: onStepCancel,
                  )
                ],
              );
            },
            onStepContinue: next,
            onStepCancel: request,
            onStepTapped: (step) => goTo(step),
          ),
        ),
      ],
    );
  }
}


class Permissions extends StatefulWidget {
  @override
  _PermissionsState createState() => _PermissionsState();
}

class _PermissionsState extends State<Permissions> {

  static bool servicesEnabled = false;
  static bool permissionGiven = false;

  @override
  void initState(){
    super.initState();
    checkPermissionsAndServices();
  }

  checkPermissionsAndServices() async {
    bool serv = await isLocationServiceEnabled();
    bool perm = await isLocationPermissionGranted();
    setState(() {
      servicesEnabled = serv;
      permissionGiven = perm;
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
    if(!permissionGiven){
      bool success = await requestLocationPermission();
      if(success){
        setState(() {
          permissionGiven = true;
        });
      }
    }
    if(servicesEnabled && permissionGiven){
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
                                            color: permissionGiven ?
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
                                      permissionGiven ?
                                      "ENABLED" :
                                      "ENABLE",
                                      style: TextStyle(
                                        color: permissionGiven ?
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






















