import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "dart:ui";
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final storage = new FlutterSecureStorage();
  final loginResponse = List<Widget>();

  bool _clicked = false;
  double _opacity = 1.0;
  bool enableButton = true;

  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();

  final headingLabelStyle = TextStyle(
    color: Colors.white,
    fontSize: 25,
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

  void changeLoginButtonState() {
    setState(() {
      _clicked = !_clicked;
      _opacity = _opacity == 1.0 ? 0.0 : 1.0;
      enableButton = true;
    });
  }

  void userLogin() async {
    setState(() {
      loginResponse.clear();
    });

    if (email.text.isEmpty) {
      createLoginResponse('Please enter your email address.');
      changeLoginButtonState();
      return;
    }

    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email.text.trim());
    if (!emailValid) {
      createLoginResponse('Email is invalid.');
      changeLoginButtonState();
      return;
    }

    if (password.text.isEmpty) {
      createLoginResponse('Please enter a password.');
      changeLoginButtonState();
      return;
    }

    String bearerToken = String.fromEnvironment('BEARER_TOKEN',
        defaultValue: DotEnv().env['BEARER_TOKEN']);

    await storage.deleteAll();
    Map data = {"email": email.text.trim(), "password": password.text.trim()};
    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $bearerToken'
    };

    var response = await http.post(
        "https://drivertracker-api.herokuapp.com/api/drivers/authenticate",
        headers: requestHeaders,
        body: data);
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      await storage.write(key: 'id', value: responseData['id']);
      await storage.write(key: 'token', value: responseData['token']);
      await storage.write(key: 'name', value: responseData['name']);
      await storage.write(key: 'surname', value: responseData['surname']);
      await storage.write(key: 'loginstatus', value: 'true');
      await storage.write(key: 'email', value: email.text);

      changeLoginButtonState();
      Navigator.of(context)
          .pushReplacementNamed('/delivery', arguments: responseData['token']);
      storage.write(key: 'loginstatus', value: 'true');
    } else //invalid credentials
    {
      String errorResponse = '';

      switch (response.statusCode) {
        case 401:
          errorResponse = 'Incorrect Email or password!';
          break;
        case 404:
          errorResponse = 'This email has not been registered!';
          break;
        case 500:
          errorResponse = 'Service is currently unavailable';
          break;
      }

      changeLoginButtonState();
      createLoginResponse(errorResponse);
    }
  }

  Widget _username() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: headingLabelStyle,
        ),
        SizedBox(height: 20.0, width: 100.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: new BoxDecoration(
            border: Border.all(color: Colors.grey[100], width: 4),
            color: Colors.transparent,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3))
            ],
          ),
          height: 60.0,
          child: TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
                color: Colors.white,
                fontFamily: "OpenSans-Regular",
                fontSize: 22),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 9.0),
              prefixIcon: Icon(Icons.email, color: Colors.grey[100], size: 30),
              hintStyle: hintLabelStyle,
              hintText: "Enter your Email",
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
          'Password',
          style: headingLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: new BoxDecoration(
            border: Border.all(color: Colors.grey[100], width: 4),
            color: Colors.transparent,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
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
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.grey[100],
                size: 30,
              ),
              hintText: "Enter your Password",
              hintStyle: hintLabelStyle,
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
        onPressed: () => {Navigator.of(context).pushNamed('/forgotPassword')},
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
    return Stack(
      children: <Widget>[
        AbsorbPointer(
          absorbing: !enableButton,
          child: InkWell(
            onTap: () {
              setState(() {
                _clicked = !_clicked;
                _opacity = _opacity == 1.0 ? 0.0 : 1.0;
                enableButton = false;
              });
            },
            child: AnimatedContainer(
              width: _clicked ? 55 : MediaQuery.of(context).size.width * 0.80,
              height: 55,
              curve: Curves.fastOutSlowIn,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_clicked ? 70.0 : 30.0),
                color: Colors.white,
              ),
              duration: Duration(milliseconds: 700),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AnimatedOpacity(
                    duration: Duration(seconds: 1),
                    child: Text(
                      "LOGIN",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: "OpenSans-Regular"),
                    ),
                    opacity: _opacity,
                  ),
                ],
              ),
            ),
          ),
        ),
        AbsorbPointer(
          absorbing: !enableButton,
          child: InkWell(
            onTap: () {
              setState(() {
                _clicked = !_clicked;
                _opacity = _opacity == 1.0 ? 0.0 : 1.0;
                enableButton = false;
              });
              userLogin();
            },
            child: AnimatedContainer(
              width: _clicked ? 55 : MediaQuery.of(context).size.width * 0.80,
              height: 55,
              curve: Curves.fastOutSlowIn,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_clicked ? 70.0 : 30.0),
              ),
              duration: Duration(milliseconds: 700),
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 700),
                child: Padding(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.blue,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        _clicked ? Colors.black : Colors.blue),
                  ),
                  padding: EdgeInsets.all(1),
                ),
                opacity: _opacity == 0.0 ? 1.0 : 0.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("assets/images/login.jpg"),
                ),
              ),
            ),
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
                            "Sign In",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'OpenSans',
                              fontSize: 35.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 30.0),
                          _username(),
                          SizedBox(height: 30.0),
                          _password(),
                          _forgetPassword(),
                          _button(),
                          Container(
                            padding: EdgeInsets.only(bottom: 0.0),
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 100.0),
                              child: Text(
                                "By CTRL-ALT-ELITE",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
