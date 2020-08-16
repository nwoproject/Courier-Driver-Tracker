import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:courier_driver_tracker/services/location/geolocator_service.dart';
import 'package:courier_driver_tracker/services/location/google_maps.dart';
import "dart:io" show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  var userData = {
    'name' : 'name',
    'surname': 'surname'
  };

  Future<Null> readUserData() async {
    var name = await storage.read(key: 'name');
    var surname = await storage.read(key: 'surname');
    setState(() {
      return userData = {
        'name' : name,
        'surname': surname,
      };
    });
  }

  @override
  void initState(){
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: new Drawer(
          child: new ListView(
            children: <Widget>[
              new UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
                accountName:Text(""),
                accountEmail: new Text(""),   // data should be pulled from database
                currentAccountPicture: new CircleAvatar(
                    backgroundColor: Colors.white,
                    child: new Text("")
                ),
              ),
              new ListTile(
                title: new Text("Deliveries"),
                trailing: new Icon(Icons.local_shipping),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed("/delivery");
                },
              ),
              new ListTile(
                title: new Text("Settings"),
                trailing: new Icon(Icons.settings),
              ),
              new Divider(height: 10.0),
              new ListTile(
                title: new Text("Close"),
                trailing: new Icon(Icons.close),
                onTap: () => Navigator.of(context).pop(),
              )
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
            Expanded(child: GMap()),
          ],
        ),
      ),
    );
  }
}
