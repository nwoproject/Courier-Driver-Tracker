import 'package:courier_driver_tracker/screens/deliveryScreen.dart';
import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/home.dart';
import 'screens/splash_screen.dart';
import 'screens/abnormalityReporting.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch(settings.name){
      case '/':
        return MaterialPageRoute(builder: (_)=>SplashScreen(),);
        break;
      case '/login':
        return MaterialPageRoute(builder: (_)=>LoginPage(),);
        break;

      case '/home':
        String token = settings.arguments;
        if(token.isNotEmpty)
        {
          return MaterialPageRoute(builder: (_)=>HomePage(),);
        }
        else
        {
          return MaterialPageRoute(builder: (_)=>LoginPage(),);
        }
        break;

      case '/report':
       return MaterialPageRoute(builder: (_) => UserFeedback(),);

      case '/delivery':
        return MaterialPageRoute(builder: (_)=>DeliveryScreen(),);

      default: //If page is not found, redirect to loginpage
        return MaterialPageRoute(builder: (_)=>LoginPage(),);
        break;
    }
  }
}

