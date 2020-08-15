import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String latitude = 'N/A';
  String longitude = 'N/A';

  void startTracking() {
    /* After the implementation of the location service, this function should
    start the service, another function is needed to update the two String 
    variables that holds the coordinates and to continuously update the two
    text widgets that displays them for demo1*/
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: Color(0xffCEE5F2),
        body: Column(
          children: <Widget>[
            Container(
              height: 100,
            ),
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
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    leading: Container(
                        padding: EdgeInsets.only(right: 12.0),
                        decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(
                                  width: 1.0, color: Colors.white24)),
                        ),
                        child: Icon(Icons.pin_drop, color: Colors.white)),
                    title: Text(
                      'Current Location',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Row(
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
                ),
              ),
            ),
            Container(
              height: 100,
            ),
            InkWell(
              onTap: () {
                startTracking();
              },
              child: Container(
                width: 250,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Color(0xff2B2C28),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Start Location Tracking",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
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
