import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserFeedback extends StatelessWidget {
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

enum Abnormality { fuelstop, lunch, traffic, other }

class Feedback extends StatefulWidget {
  Feedback({Key key}) : super(key: key);

  @override
  _FeedbackState createState() => _FeedbackState();
}

class _FeedbackState extends State<Feedback> {
  Abnormality _character = Abnormality.fuelstop;
  TextEditingController _controller;
  TextEditingController textController;
  String other;

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
      report();
    }
  }

  void responseCheck(String r) {
    Fluttertoast.showToast(
        msg: r,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  void report() async {
    String resp = "";

    if (_character == Abnormality.fuelstop) {
      resp = "Filled the vehicle with fuel";
    }
    if (_character == Abnormality.lunch) {
      resp = "Stopped for lunch";
    }
    if (_character == Abnormality.traffic) {
      resp = "Filled the vehicle with fuel";
    }
    if (_character == Abnormality.other) {
      resp = other;
    }

    String bearerToken = String.fromEnvironment('BEARER_TOKEN',
        defaultValue: DotEnv().env['BEARER_TOKEN']);

    Map data = {
      "code": 100,
      "token": bearerToken,
      "description": resp,
      "latitude": "-25.7",
      "longitude": "28.7",
      "timestamp": "2020-08-11 09:00:00"
    };

    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $bearerToken'
    };

    var response = await http.post(
        "https://drivertracker-api.herokuapp.com/api/abnormalities/:driver?id",
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
          title: const Text('Filling up vehicle'),
          value: Abnormality.fuelstop,
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
          title: const Text('Stopped for lunch break'),
          value: Abnormality.lunch,
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
          title: const Text('Severe traffic'),
          value: Abnormality.traffic,
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
              border: InputBorder.none, hintText: 'Specify reason'),
        ),
        const SizedBox(height: 30),
        RaisedButton(
          onPressed: () {
            checkForEmptyText();
          },
          child: const Text('Submit', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}
