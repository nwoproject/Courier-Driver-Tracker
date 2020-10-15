import 'package:courier_driver_tracker/services/abnormality/abnormality_service.dart';
import 'package:courier_driver_tracker/services/file_handling/route_logging.dart';
import 'package:courier_driver_tracker/services/location/geolocator_service.dart';
import 'package:geolocator/geolocator.dart';

class BackgroundService {
  factory BackgroundService() => _instance;

  BackgroundService._internal();

  static final _instance = BackgroundService._internal();

  static final GeolocatorService _geolocatorService = GeolocatorService();
  static final AbnormalityService _abnormalityService = AbnormalityService();
  static final RouteLogging _logger = RouteLogging();

  void trackDriver() async{
    while(true){
      await Future.delayed(Duration(milliseconds: 5000), () async {
          Position current = await _geolocatorService.getPosition();
          _abnormalityService.setCurrentLocation(current);
          _logger.writeToFile(current.toString(), "locationFile");
      });
    }
  }
}