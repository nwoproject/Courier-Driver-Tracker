import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:courier_driver_tracker/services/location/geolocator_service.dart';
import 'package:courier_driver_tracker/services/api_handler/api.dart';
import 'package:courier_driver_tracker/services/api_handler/uncalculated_route_model.dart' as delivery;
import 'package:courier_driver_tracker/services/navigation/navigation_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserFeedbackAfterDelivery extends StatelessWidget {
  static const String _title = 'Delivery response';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(_title),
          backgroundColor: Colors.grey[900],
        ),
        body: Center(
          child: Feedback(),
        ),
      ),
    );
  }
}

enum Abnormality { succ, fail, other }

class Feedback extends StatefulWidget {
  Feedback({Key key}) : super(key: key);

  @override
  _FeedbackState createState() => _FeedbackState();
}

class _FeedbackState extends State<Feedback> {
  Abnormality _character = Abnormality.succ;
  TextEditingController _controller;
  TextEditingController textController;
  String other;
  final storage = new FlutterSecureStorage();

  GeolocatorService geolocatorService = new GeolocatorService();
  Position position;

  void initState() {
    super.initState();
    _controller = TextEditingController();
    textController = TextEditingController();
  }

  void dispose() {
    _controller.dispose();
    textController.dispose();
    super.dispose();
  }


  void checkForEmptyText() {
    other = textController.text;

    if ((other == "") && (_character == Abnormality.other)) {
      Fluttertoast.showToast(
          msg: 'Please specify the reason for this abnormality.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    } else {
      textController.clear();
      report();
    }
  }

  void responseCheck(String r) {
//    if (r != null){
//      homePage();
//    }
    Fluttertoast.showToast(
        msg: r,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white);
  }

  double calculateDistanceBetween(LatLng currentPosition, LatLng lastPosition){
    double p = 0.017453292519943295;
    double a = 0.5 - cos((currentPosition.latitude - lastPosition.latitude) * p)/2 +
        cos(lastPosition.latitude * p) * cos(currentPosition.latitude * p) *
            (1 - cos((currentPosition.longitude - lastPosition.longitude) * p))/2;
    return 12742 * asin(sqrt(a)) * 1000;
  }


  void report() async {

    ApiHandler _api = ApiHandler();

    position = await geolocatorService.getPosition();
    String currentRoute = await storage.read(key: "current_route");
    int index = int.parse(currentRoute);

    List<delivery.Route> routes = await _api.getUncalculatedRoute();
    List<delivery.Location> location;

    var currPos = LatLng(position.latitude, position.longitude);

    location = routes[index].locations;

    double distance = 855555555;
    var tempLocID;

    for (int k = 0; k < location.length; k++) {
      var tempDistance = calculateDistanceBetween(currPos, LatLng(double.parse(location[k].latitude), double.parse(location[k].longitude)));
      if (tempDistance < distance)
        {
          distance = tempDistance;
          tempLocID = location[k].locationID;
        }
    }

    tempLocID = tempLocID.toString();
    String resp = "";

    if (_character == Abnormality.succ) {
      resp = "Delivery was made successful made.";
    }
    if (_character == Abnormality.fail) {
      resp = "No one was available to collect the delivery.";
    }
    if (_character == Abnormality.other) {
      resp = other;
    }

    String respCode;
    var response = await _api.completeDelivery(tempLocID, position);

    switch (response) {
      case 204:
        respCode = "Timestamp successfully stored.";
        responseCheck(respCode);
        break;
      case 400:
        respCode = "Bad request (missing parameters in request body)";
        responseCheck(respCode);
        break;
      case 401:
        respCode = "Unauthorized (incorrect id and token combination).";
        responseCheck(respCode);
        break;
      case 404:
        respCode = "Location with that :locationid does not exist.";
        responseCheck(respCode);
        break;
      case 500:
        respCode = "Server error";
        responseCheck(respCode);
        break;
    }
  }

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RadioListTile(
          title: const Text(
            'Delivery was made successful made.',
            style: TextStyle(
              fontSize: 17,
              fontFamily: 'OpenSans-Regular',
            ),
          ),
          value: Abnormality.succ,
          groupValue: _character,
          onChanged: (Abnormality value) {
            print(value);
            setState(() {
              _character = value;
            });
          },
          secondary: new Icon(Icons.add_circle),
        ),
        RadioListTile(
          title: const Text(
            'No one was available to collect the delivery.',
            style: TextStyle(
              fontSize: 17,
              fontFamily: 'OpenSans-Regular',
            ),
          ),
          value: Abnormality.fail,
          groupValue: _character,
          onChanged: (Abnormality value) {
            print(value);
            setState(() {
              _character = value;
            });
          },
          secondary: new Icon(Icons.add_circle),
        ),
        RadioListTile(
          title: const Text(
            'Other (Specify)',
            style: TextStyle(
              fontSize: 17,
              fontFamily: 'OpenSans-Regular',
            ),
          ),
          value: Abnormality.other,
          groupValue: _character,
          onChanged: (Abnormality value) {
            print(value);
            setState(() {
              _character = value;
            });
          },
          secondary: new Icon(Icons.add_circle),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0),
          child: Container(
            decoration: new BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.grey[900], width: 2))),
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Specify reason'),
            ),
          ),
        ),
        const SizedBox(height: 30),
        RaisedButton(
          elevation: 5.0,
          color: Colors.grey[900],
          onPressed: () {
            checkForEmptyText();
          },
          child: const Text('Submit',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              )),
        ),
      ],
    );
  }
}
