import 'package:courier_driver_tracker/services/navigation/navigation_service.dart';
import 'package:courier_driver_tracker/services/location/geolocator_service.dart';
import 'package:geolocator/geolocator.dart';

class BackgroundService {
  factory BackgroundService() => _instance;

  BackgroundService._internal();

  static final _instance = BackgroundService._internal();

  GeolocatorService _geolocatorService = GeolocatorService();
  NavigationService _navigationService = NavigationService();

  void trackDriver() async{
    print("Doing something");
    while(true){
      Position current = await _geolocatorService.getPosition();
      print("Tracking at ${current.longitude} - ${current.latitude}");
      await Future.delayed(Duration(milliseconds: 5000), (){});
    }
  }
}