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
  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
  }
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
            RichText(
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
























