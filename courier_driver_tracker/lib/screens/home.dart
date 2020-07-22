import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:courier_driver_tracker/services/location/geolocator_service.dart';
import 'package:courier_driver_tracker/services/location/google_maps.dart';

import "dart:io" show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

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

  @override
  void initState(){
    super.initState();
    startServiceInPlatform();
  }

  void startServiceInPlatform() async{
    if(Platform.isAndroid){
      var methodChannel = MethodChannel("com.ctrlaltelite.messages");
      String data = await methodChannel.invokeMethod("startService");
      print(data);
    }
  }

  @override
  Widget build(BuildContext context) {

    // Position trackingData = Provider.of<Position>(context);

    return SafeArea(
      child: Scaffold(
        drawer: new Drawer(
          child: new ListView(
            children: <Widget>[
              new UserAccountsDrawerHeader(
                accountName: new Text("username"),
                accountEmail: new Text("username@gmail.com"),
                currentAccountPicture: new CircleAvatar(
                    backgroundColor: Colors.white,
                    child: new Text("U")
                ),
              ),
              new ListTile(
                title: new Text("Deliveries"),
                trailing: new Icon(Icons.local_shipping),
              ),
              new ListTile(
                title: new Text("Settings"),
                trailing: new Icon(Icons.settings),
              ),
              new Divider(),
            ],
          ),
        ),
        body: Column(
          children: <Widget>[
            AppBar(
              backgroundColor: Colors.black,
              title: Text(
                  'Route',
                      style: TextStyle(
                        color: Colors.white,
                      ),
              ),
            ),

            Expanded(
                child: GMap()
            ),
          ],
        ),
      ),
    );
  }
}
