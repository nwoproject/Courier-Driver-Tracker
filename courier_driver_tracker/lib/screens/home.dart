import 'dart:ui';

import 'package:courier_driver_tracker/services/api_handler/api.dart';
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
import 'dart:async';

import 'package:courier_driver_tracker/services/background/background_main.dart';
import 'package:courier_driver_tracker/services/background/background_service.dart';
import 'package:courier_driver_tracker/services/background/background_widget.dart';

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
  ApiHandler api = new ApiHandler();

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
  var _backgroundChannel = MethodChannel("com.ctrlaltelite/background_service");
  var callbackHandle = PluginUtilities.getCallbackHandle(backgroundMain);

  bool _visible = false;




  @override
  void initState() {
    //readUserData();
    super.initState();
    _backgroundChannel.invokeMethod('startService', callbackHandle.toRawHandle());

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _pushScreens(context));
  }

  _pushScreens(BuildContext context) {
    Navigator.of(context).pushNamed('/splash');
    setState(() {
      _visible = true;
    });
  }

  void startServiceInPlatform() async {
    if (Platform.isAndroid) {
      var _backgroundChannel = MethodChannel("com.ctrlaltelite.background");
      String data = await _backgroundChannel.invokeMethod("startService");
      print(data);
      const seconds = const Duration(seconds: 45);
      Timer.periodic(seconds, (Timer t) => api.updateDriverLocationNoCoords());
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
    return WillPopScope(
        onWillPop: () {
          if (Platform.isAndroid) {
            if (Navigator.of(context).canPop()) {
              return Future.value(true);
            } else {
              _backgroundChannel.invokeMethod("sendToBackground");
              return Future.value(false);
            }
          } else {
            return Future.value(true);
          }
        },
    child:Scaffold(

        bottomNavigationBar: _buildBottomNavigationBar,
        body: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: Duration(milliseconds: 200),
          child: GMap(),
        )

      )
    );
  }

  Widget get _buildBottomNavigationBar {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      child: ClipRRect(
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
                }
                else if (index == 2) {
                  Navigator.of(context).pushNamed("/profile");
                }
                else if (index == 3) {
                  Navigator.of(context).pushNamed("/settings");
                }
              })),
    );
  }
}
