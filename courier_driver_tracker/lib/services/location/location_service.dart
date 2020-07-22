import 'package:flutter/services.dart';

class LocationService {

  static const EventChannel _eventChannel = const EventChannel("com.ctrlaltelite.locationstream");
  static Stream<String> _locationStream;


  Stream<String> get locationStream {
    if(_locationStream == null){
      _locationStream = _eventChannel.receiveBroadcastStream().map<String>((position) => position);
      print("Started receiving");

    }
    return _locationStream;
  }

}
