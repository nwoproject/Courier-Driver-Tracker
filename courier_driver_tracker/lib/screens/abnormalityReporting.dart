import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  bool textNeeded = false;

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

  checkForEmptyText() {
    String other;

    other = textController.text;

    if ((_character == Abnormality.other) && (other == "")) {
      textNeeded = true;
      Fluttertoast.showToast(
          msg: 'Please specify the reason for this abnormality.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white
      );
    }
    else {
      if(textNeeded == false) {
        report();
      }
    }
  }

  bool report() {
    if (_character == Abnormality.fuelstop)
      {
        //write to database
        return true;
      }
    if (_character == Abnormality.lunch)
    {
      //write to database
      return true;
    }
    if (_character == Abnormality.traffic)
    {
      //write to database
      return true;
    }
    if (_character == Abnormality.other)
    {
      //write to database
      return true;
    }
    return false;
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
              border: InputBorder.none,
              hintText: 'Specify reason'
          ),
        ),

        const SizedBox(height: 30),
        RaisedButton(
          onPressed: (){
            checkForEmptyText();
            },
          child: const Text('Submit', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}
