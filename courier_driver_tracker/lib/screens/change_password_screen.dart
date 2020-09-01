import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "dart:ui";
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage>
    with SingleTickerProviderStateMixin {
  final loginResponse = List<Widget>();

  TextEditingController newPassword = new TextEditingController();
  TextEditingController password = new TextEditingController();

  final headingLabelStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontFamily: 'OpenSans-Regular',
  );
  final hintLabelStyle = TextStyle(
      color: Colors.white.withOpacity(0.8),
      fontFamily: 'OpenSans-Regular',
      fontSize: 20);

  void createLoginResponse(String response) {
    var errorWidget = Card(
      color: Colors.red[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.warning, color: Colors.red[300]),
          Padding(padding: EdgeInsets.only(right: 10.0)),
          Padding(padding: EdgeInsets.only(bottom: 30.0)),
          Text(
            response,
            style: TextStyle(
              color: Colors.black.withOpacity(0.8),
              fontFamily: "OpenSans-Regular",
            ),
          ),
        ],
      ),
    );

    setState(() {
      loginResponse.add(errorWidget);
    });
  }

  final storage = new FlutterSecureStorage();
  var userData = {
    'name': 'name',
    'surname': 'surname',
    'email': 'email',
    'id': 'id',
    'token': 'token'
  };

  Future<Null> readUserData() async {
    var name = await storage.read(key: 'name');
    var surname = await storage.read(key: 'surname');
    var email = await storage.read(key: 'email');
    var id = await storage.read(key: 'id');
    var token = await storage.read(key: 'token');
    setState(() {
      return userData = {
        'name': name,
        'surname': surname,
        'email': email,
        'id': id,
        'token': token
      };
    });
  }

  @override
  void initState() {
    readUserData();
    super.initState();
  }

  void userLogin() async {
    setState(() {
      loginResponse.clear();
    });

    if (password.text.isEmpty) {
      createLoginResponse('Please enter your existing password.');
      return;
    }

    if (newPassword.text.isEmpty) {
      createLoginResponse('Please enter a new password');
      return;
    }

    if (newPassword.text.length < 7) {
      createLoginResponse('New password is to short');
      return;
    }

    String bearerToken = String.fromEnvironment('BEARER_TOKEN',
        defaultValue: DotEnv().env['BEARER_TOKEN']);
    String token = userData['token'];
    await storage.deleteAll();
    Map data = {"email": userData['email'], "password": password.text.trim()};
    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $bearerToken'
    };
    Map data2 = {"password": password.text.trim(), "token": '$token'};

    var response = await http.post(
        "https://drivertracker-api.herokuapp.com/api/drivers/authenticate",
        headers: requestHeaders,
        body: data);
    if (response.statusCode != 200) //invalid credentials
    {
      print(response.statusCode);
      String errorResponse = '';

      switch (response.statusCode) {
        case 401:
          errorResponse = 'Incorrect password!';
          break;
        case 404:
          errorResponse = 'your email has not been registered!';
          break;
        case 500:
          errorResponse = 'Service is currently unavailable';
          break;
      }
      createLoginResponse(errorResponse);
    }
    String userId = userData["id"];

    var response2 = await http.post(
        "https://drivertracker-api.herokuapp.com/api/drivers/$userId/password",
        headers: requestHeaders,
        body: data2);
    if (response.statusCode == 200 && response2.statusCode == 204) {
      var responseData = json.decode(response.body);
      Navigator.of(context)
          .pushNamed('/home', arguments: responseData['token']);
    } else //invalid credentials
    {
      print(response2.statusCode);
      String errorResponse = '';

      switch (response2.statusCode) {
        case 204:
          errorResponse = 'Password has been updated';
          break;
        case 404:
          errorResponse = 'Invalid :driverid or token';
          break;
        case 500:
          errorResponse = 'Service is currently unavailable';
          break;
      }
      createLoginResponse(errorResponse);
    }
  }

  Widget _newPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Enter your new password',
          style: headingLabelStyle,
        ),
        SizedBox(height: 20.0, width: 100.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: new BoxDecoration(
            border:
                Border(bottom: BorderSide(color: Colors.grey[100], width: 4)),
            color: Colors.transparent,
          ),
          height: 60.0,
          child: TextField(
            controller: newPassword,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            style: TextStyle(
                color: Colors.white,
                fontFamily: "OpenSans-Regular",
                fontSize: 22),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 9.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _password() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Enter your password',
          style: headingLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: new BoxDecoration(
            border:
                Border(bottom: BorderSide(color: Colors.grey[100], width: 4)),
            color: Colors.transparent,
          ),
          height: 60.0,
          child: TextField(
            controller: password,
            obscureText: true,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontFamily: "OpenSans-Regular",
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 9.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _forgetPassword() {
    return Container(
      alignment: Alignment.centerRight,
      child: FlatButton(
        onPressed: () => {"implementation missing"},
        padding: EdgeInsets.only(right: 0.0),
        child: Text(
          "Forgot Password?",
          style: TextStyle(
            color: Color(0xFFFF1B1C),
            fontFamily: 'OpenSans-Regular',
          ),
        ),
      ),
    );
  }

  Widget _button() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () => {userLogin()},
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          "Submit",
          style: TextStyle(
              color: Colors.black,
              letterSpacing: 1.5,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              fontFamily: "OpenSans-Regular"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 100.0,
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: loginResponse +
                      <Widget>[
                        Text(
                          "Change Password",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'OpenSans',
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          decoration: new BoxDecoration(),
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 30.0),
                              _password(),
                              SizedBox(height: 30.0),
                              _newPassword(),
                              _forgetPassword(),
                            ],
                          ),
                        ),
                        _button(),
                      ]),
            ),
          ),
        ],
      ),
    );
  }
}
