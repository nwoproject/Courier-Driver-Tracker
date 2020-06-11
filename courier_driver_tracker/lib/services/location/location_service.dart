import 'dart:async';
import 'package:courier_driver_tracker/services/location/TrackingData.dart';
import 'package:location/location.dart';

class LocationService{
  TrackingData trackingData;

  Location location = Location();

  // Continuous location stream
  StreamController<TrackingData> coordinateController =
  StreamController<TrackingData>.broadcast();

  Stream<TrackingData> get locationStream => coordinateController.stream;


  Future<bool> getPermissions() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  LocationService() {
    // Check permissions
    getPermissions().then((granted) {
      if (granted != null) {
        location.onLocationChanged.listen((locationData) {
          if (locationData != null) {
            coordinateController.add(TrackingData(
                latitude: locationData.latitude,
                longitude: locationData.longitude
            ));
          }
        });
      }
    });
  }


  Future<TrackingData> getLocation() async {
    try {
      var courierLocation = await location.getLocation();
      trackingData = TrackingData(
          latitude: courierLocation.latitude,
          longitude: courierLocation.longitude
      );
    } catch (error) {
      print('Failed to retrieve Location: $error');
    }

    return trackingData;
  }

  void closeStream() {
    coordinateController.close();
  }
}

