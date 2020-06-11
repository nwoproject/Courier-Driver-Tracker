import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courier_driver_tracker/services/location/TrackingData.dart';
import 'package:courier_driver_tracker/services/location/location_service.dart';
import 'package:courier_driver_tracker/services/location/google_maps.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    @override
  Widget build(BuildContext context) {

    return StreamProvider<TrackingData>(
      create: (context) => LocationService().locationStream,
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
  Widget build(BuildContext context) {
    String latitude = 'N/A';
    String longitude = 'N/A';
    TrackingData trackingData = Provider.of<TrackingData>(context);



    if(trackingData != null){
      latitude = '${trackingData.latitude}';
      longitude = '${trackingData.longitude}';
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(
            child: Text('Location Tracking Test',style: TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: Color(0xff2B2C28),
        ),
        backgroundColor: Colors.black,
        body: Column(
          children: <Widget>[
            Expanded(
                flex: 5,
                child: GMap()
            ),
            SizedBox(height: 12.0),
            Container(
              child: Card(
                shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)
                ),
                elevation: 8.0,
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xff2B2C28),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        contentPadding:
                        EdgeInsets.fromLTRB(20.0, 10.0, 0.0, 0.0),
                        leading: Icon(Icons.pin_drop, color: Colors.white),
                        title: Text(
                          'Current Location',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Latitude: $latitude',
                              style: TextStyle(color : Colors.white),
                            ),
                            Container(
                              width: 20,
                            ),
                            Text(
                              'Longitude: $longitude',
                              style: TextStyle(color : Colors.white),
                            ),
                          ],
                        ),
                      ),
                        ],
                      ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
