import 'package:courier_driver_tracker/screens/change_password_screen.dart';
import 'package:courier_driver_tracker/screens/company_car.dart';
import 'package:courier_driver_tracker/screens/delivery.dart';
import 'package:courier_driver_tracker/screens/forgot_passsword_screen.dart';
import 'package:courier_driver_tracker/screens/delivery_screen.dart';
import 'package:courier_driver_tracker/screens/long_stop.dart';
import 'package:courier_driver_tracker/screens/off_route.dart';
import 'package:courier_driver_tracker/screens/profile.dart';
import 'package:courier_driver_tracker/screens/settings.dart';
import 'package:courier_driver_tracker/screens/speed_exceeded.dart';
import 'package:courier_driver_tracker/screens/sudden_stop.dart';
import 'package:courier_driver_tracker/services/background/background_widget.dart';
import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/home.dart';
import 'screens/splash_screen.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(
          builder: (_) => SplashScreen(),
        );
        break;
      case '/login':
        return MaterialPageRoute(
          builder: (_) => LoginPage(),
        );
        break;

      case '/home':
        return MaterialPageRoute(
            builder: (_) => BackgroundWidget(child: HomePage()),
        );
        break;

      case '/home2':
        return MaterialPageRoute(
          builder: (_) => HomePage(),
        );
        break;

      case '/profile':
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(),
        );
        break;

      case '/settings':
        return MaterialPageRoute(
          builder: (_) => SettingsScreen(),
        );
      case '/reportLong':
        return MaterialPageRoute(
          builder: (_) => UserFeedbackLong(),
        );
        break;

      case '/reportSudden':
        return MaterialPageRoute(
          builder: (_) => UserFeedbackSudden(),
        );
        break;

      case '/reportOff':
        return MaterialPageRoute(
          builder: (_) => UserFeedbackOffRoute(),
        );
        break;

      case '/reportSpeed':
        return MaterialPageRoute(
          builder: (_) => UserFeedbackSpeed(),
        );
        break;

      case '/reportCompany':
        return MaterialPageRoute(
          builder: (_) => UserFeedbackLongCompany(),
        );
        break;

      case '/reportDelivery':
        return MaterialPageRoute(
          builder: (_) => UserFeedbackAfterDelivery(),
        );
        break;

      case '/changePassword':
        return MaterialPageRoute(
          builder: (_) => ChangePasswordPage(),
        );
        break;

      case '/forgotPassword':
        return MaterialPageRoute(
          builder: (_) => ForgotPasswordPage(),
        );
        break;

      case '/delivery':
        return MaterialPageRoute(
          builder: (_) => DeliveryScreen(),
        );
        break;

      default: //If page is not found, redirect to loginpage
        return MaterialPageRoute(
          builder: (_) => LoginPage(),
        );
        break;
    }
  }
}
