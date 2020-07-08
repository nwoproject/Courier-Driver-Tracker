import 'package:flutter/material.dart';
import 'dart:async';
import "login.dart";
import "home.dart";
import 'package:courier_driver_tracker/services/location/location_permissions.dart';
import 'package:shimmer/shimmer.dart';

class SplashScreen extends StatefulWidget{
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Widget _activeWidget = Logo();

  @override
  void initState(){
    super.initState();
    _changeActiveWidget();
  }

  Future<bool> _checkFlutter() async {
    await Future.delayed(Duration(milliseconds: 5000), (){});

    return false;
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

  void _changeActiveWidget() async {
    bool service = await isLocationServiceEnabled();
    bool perm = await isLocationPermissionGranted();

    if(service && perm){
      _checkFlutter().then(
              (status){
            if(!status){
              _navigateToLogin();
            } else{
              _navigateToHome();
            }
          }
      );
    }
    else{
      setState(() => {
        _activeWidget = PermissionsStepper()
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(child: child, scale: animation);
        },
        child: _activeWidget,
      )
    );
  }
}

class Logo extends StatefulWidget {
  @override
  _LogoState createState() => _LogoState();
}

class _LogoState extends State<Logo> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(color:Colors.white),
            Shimmer.fromColors(baseColor: Colors.black,
              highlightColor: Color(0xff40c4ff),
              child:Container(
                padding: EdgeInsets.all(16.0),
                child: Text("CourierTracker",
                  style: TextStyle(
                      fontSize: 50.0,
                      fontFamily: "Pacifico",
                      shadows: <Shadow>[
                        Shadow(
                            blurRadius: 10.0,
                            color: Colors.black87,
                            offset: Offset.fromDirection(120, 12)
                        )
                      ]
                  ),
                ),),
            ),
          ],
        )
    );
  }
}
