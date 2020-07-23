import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "dart:ui";


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin{
  // The following two controllers stores the textfield values.
  TextEditingController emailController = new TextEditingController();
  TextEditingController passController = new TextEditingController();

  final headingLabelStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontFamily: 'OpenSans-Regular',
  );
  final hintLabelStyle = TextStyle(
    color: Colors.black.withOpacity(0.2),
    fontFamily: 'OpenSans-Regular',

  );

  void userLogin() {
    //Called when tapped on the Login button
    Navigator.of(context).pushNamed('/home');
  }

  Widget _username(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Username',
          style: headingLabelStyle,
        ),
        SizedBox(height: 20.0, width: 100.0),

        Container(
          alignment: Alignment.centerLeft,
          decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5)
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3)
                )
              ]
          ),
          height: 60.0,
          child: TextField(
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.black.withOpacity(0.5),
              fontFamily: "OpenSans-Regular",
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.person,
                color: Colors.black,
              ),
              hintStyle: hintLabelStyle,
              hintText: "Enter your Username",

            ),
          ),
        ),

      ],
    );
  }
  Widget _password(){
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
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5)
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3)
                )
              ]
          ),
          height: 60.0,
          child: TextField(
            obscureText: true,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: "OpenSans-Regular",
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.black,
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
          onPressed: () => {"implementation missing"},
          padding: EdgeInsets.only(right: 0.0),
          child: Text(
            "Forgot Password?",
            style: TextStyle(
              color: Color(0xFFFF1B1C),

              fontFamily: 'OpenSans-Regular',
            ),

          )
      ),
    );
  }

  Widget _button(){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () => userLogin(),
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          "LOGIN",
          style: TextStyle(
              color: Colors.black,
              letterSpacing: 1.5,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              fontFamily: "OpenSans-Regular"
          ),
        ),

      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                  image: AssetImage("assets/images/login.jpg"),

                )
            ),
          ),
          Container(
            height: double.infinity,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding:  EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 120.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Sign In",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'OpenSans',
                      fontSize: 30.0,
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
                    child: Text(
                      "By CTRL-ALT-ELITE",
                      style: TextStyle(
                        color: Colors.white,

                      ),
                    ),

                  )],
              ),


            ),
          )
        ],
      ),

    );
  }
}
