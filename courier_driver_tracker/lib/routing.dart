import 'package:flutter/material.dart';
import "screens/login.dart";
import 'screens/home.dart';
import 'screens/splash_screen.dart';

// This class will serve as a navigator between screens, if a new screen is created add it here.
// This will make session management as well has passing data between screens easier.
// No session validation checks are needed for now. 

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch(settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_)=>SplashScreen(),);

      case '/login':
        return MaterialPageRoute(builder: (_)=>LoginPage(),);

      case '/home':
        return MaterialPageRoute(builder: (_)=>HomePage(),);

      default: //If page is not found, redirect to loginpage
        return MaterialPageRoute(builder: (_)=>LoginPage(),);
    }
  }
}

