import 'dart:async';
import 'package:geolocator/geolocator.dart';

class GeolocatorService{
  StreamSubscription<Position> _positionStreamSubscription;
  // todo
  // positions still need to be stored
  // List<Position> _positions = <Position>[];

  static const LocationOptions locationOptions = LocationOptions(
    accuracy: LocationAccuracy.best);
  final Stream<Position> positionStream = Geolocator().getPositionStream(locationOptions);

  Stream<Position> get locationStream => positionStream;

  void dispose(){
    if(_positionStreamSubscription != null){
      _positionStreamSubscription.cancel();
      _positionStreamSubscription = null;
    }
  }

  Future<Position> getPosition() async {
   return await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high, locationPermissionLevel: GeolocationPermission.locationAlways);
  }

  Future<String> getAddress(Position position) async {
    String address = 'unkown';
    final List<Placemark> placemarks = await Geolocator()
      .placemarkFromCoordinates(position.latitude, position.longitude);

    if(placemarks != null && placemarks.isNotEmpty){
      address = _buildAddressString(placemarks.first);
    }

    return address;
  }

  static String _buildAddressString(Placemark placemark){
    final String name = placemark.name ?? '';
    final String city = placemark.locality ?? '';
    final String state = placemark.administrativeArea ?? '';
    final String country = placemark.country ?? '';
    final Position position = placemark.position;

    return '$name, $city, $state, $country\n$position';
  }

  Future<List<String>> getCoordinatesFromAddress(String address) async {
    final Geolocator _geolocator = Geolocator();
    List<String> _placemarkCoords = [];
    final List<Placemark> placemarks = await Future(
        () => _geolocator.placemarkFromAddress(address))
      .catchError((onError) {
        print("Error occured while retrieving Coordinates from Address: " + onError);

        return Future.value(List<Placemark>());
    });

    if(placemarks != null && placemarks.isNotEmpty){
      final Placemark pos = placemarks[0];
      final List<String> coords = placemarks.map(
          (placemark) => pos.position?.latitude.toString()
              + ' ' +
          pos.position?.longitude.toString())
          .toList();
      _placemarkCoords = coords;
    }
    return _placemarkCoords;
  }

  String convertPositionToString(Position position){
    String positionString = "";
    positionString += position.latitude.toString() + ",";
    positionString += position.longitude.toString() + ",";
    positionString += position.accuracy.toString() + ",";
    positionString += position.heading.toString() + ",";
    positionString += position.speed.toString() + ",";
    positionString += position.timestamp.toString();

    return positionString;
  }


}