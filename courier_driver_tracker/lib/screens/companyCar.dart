import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:courier_driver_tracker/services/location/geolocator_service.dart';

class UserFeedbackLongCompany extends StatelessWidget {
  static const String _title = 'Abnormality Feedback';

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

enum Abnormality { forgot, arranged, other }

class Feedback extends StatefulWidget {
  Feedback({Key key}) : super(key: key);

  @override
  _FeedbackState createState() => _FeedbackState();
}

class _FeedbackState extends State<Feedback> {
  Abnormality _character = Abnormality.forgot;
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

//  void homePage() async{
//    Navigator.of(context).pop();
//  }

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

  void report() async {
    position = await geolocatorService.getPosition();
    var token = await storage.read(key: 'token');
    var driverID = await storage.read(key: 'id');
    driverID = driverID.toString();
    String lat = position.latitude.toString();
    String long = position.longitude.toString();
    String time = position.timestamp.toString();

    String resp = "";

    if (_character == Abnormality.forgot) {
      resp = "I forgot to turn off the app.";
    }
    if (_character == Abnormality.arranged) {
      resp = "I have arranged with the manager.";
    }
    if (_character == Abnormality.other) {
      resp = other;
    }

    String bearerToken = String.fromEnvironment('BEARER_TOKEN',
        defaultValue: DotEnv().env['BEARER_TOKEN']);

    print(lat);
    print(long);
    print(time);
    Map data = {
      "code": "104",
      "token": token,
      "description": resp,
      "latitude": lat,
      "longitude": long,
      "timestamp": time
    };

    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $bearerToken'
    };

    var response = await http.post(
        "https://drivertracker-api.herokuapp.com/api/abnormalities/$driverID",
        headers: requestHeaders,
        body: data);

    String respCode = "";

    switch (response.statusCode) {
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
          title: const Text(
            'I forgot to turn off the app.',
            style: TextStyle(
              fontSize: 17,
              fontFamily: 'OpenSans-Regular',
            ),
          ),
          value: Abnormality.forgot,
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
            'I have arranged with the manager.',
            style: TextStyle(
              fontSize: 17,
              fontFamily: 'OpenSans-Regular',
            ),
          ),
          value: Abnormality.arranged,
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
