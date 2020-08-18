import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:courier_driver_tracker/services/location/geolocator_service.dart';
import 'package:courier_driver_tracker/screens/home.dart';


class UserFeedbackSpeed extends StatelessWidget {
  static const String _title = 'Abnormality Feedback';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: Center(
          child: Feedback(),
        ),
      ),
    );
  }
}

enum Abnormality { overtaking, unknown, other }

class Feedback extends StatefulWidget {
  Feedback({Key key}) : super(key: key);

  @override
  _FeedbackState createState() => _FeedbackState();
}

class _FeedbackState extends State<Feedback> {
  Abnormality _character = Abnormality.overtaking;
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

  void homePage() async{
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (BuildContext context) => HomePage()
        ));
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
          textColor: Colors.white
      );
    }
    else{
      textController.clear();
      report();
    }
  }

  void responseCheck(String r) {
    Fluttertoast.showToast(
        msg: r,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white
    );
  }


  void report() async{
    position = await geolocatorService.getPosition();
    var token = await storage.read(key: 'token');
    var driverID = await storage.read(key: 'id');
    driverID = driverID.toString();
    String lat = position.latitude.toString();
    String long = position.longitude.toString();
    String time = position.timestamp.toString();

    String resp = "";

    if (_character == Abnormality.overtaking)
    {
      resp = "I was overtaking another vehicle.";
    }
    if (_character == Abnormality.unknown) {
      resp = "I did not know what the speed limit was.";
    }
    if (_character == Abnormality.other)
    {
      resp = other;
    }

    String bearerToken = String.fromEnvironment('BEARER_TOKEN', defaultValue: DotEnv().env['BEARER_TOKEN']);

    print (lat);
    print (long);
    print (time);
    Map data = {
      "code": "102",
      "token": token,
      "description": resp,
      "latitude": lat,
      "longitude": long,
      "timestamp": time
    };

    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
      'Authorization':'Bearer $bearerToken'
    };

    var response = await http.post(
        "https://drivertracker-api.herokuapp.com/api/abnormalities/$driverID",
        headers: requestHeaders,
        body: data);

    String respCode ="";

    switch(response.statusCode)
    {
      case 201:
        respCode = "Abnormality was successfully logged";
        responseCheck(respCode);
        break;
      case 400:
        respCode = "Bad request (missing parameters in request body)";
        responseCheck(respCode);
        break;
      case 401:
        respCode = "Invalid :driverid and token combination";
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
          title: const Text('I was overtaking another vehicle.'),

          value: Abnormality.overtaking,
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
          title: const Text('I did not know what the speed limit was.'),

          value: Abnormality.unknown,
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
          title: const Text('Other (Specify)'),
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

        TextField(
          controller: textController,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Specify reason'
          ),
        ),

        const SizedBox(height: 30),
        RaisedButton(
          onPressed: (){
            checkForEmptyText();
            homePage();
          },
          child: const Text('Submit', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}
