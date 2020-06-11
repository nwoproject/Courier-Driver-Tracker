import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:courier_driver_tracker/services/location/TrackingData.dart';
import 'package:provider/provider.dart';


class GMap extends StatefulWidget {
  @override
  State<GMap> createState() => MapSampleState();
}

class MapSampleState extends State<GMap> {
  Completer<GoogleMapController> _controller = Completer();

  Circle circle;
  Marker marker;
  BitmapDescriptor myIcon;

  @override
  void initState() {
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 'assets/images/car_icon.png')
        .then((onValue) {
      myIcon = onValue;
    });
  }

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load('assets/images/car_icon.png');
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(TrackingData location) {
    LatLng loc = LatLng(location.latitude, location.longitude);
    this.setState(() {
      marker = Marker(
        markerId: MarkerId("courierposition"),
        position: loc,
        rotation: 192.8334901395799,
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        icon: myIcon,
      );
      circle = Circle(
        circleId: CircleId('courierlocation'),
        radius: 10.0,
        strokeColor: Colors.blue,
        center: loc,
        fillColor: Colors.blue[900]
      );
    });
  }

  Future<void> updateCamera(TrackingData location) async {
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(location.latitude, location.longitude),
      tilt: 0.0,
      zoom: 18.0
    )));
  }


  @override
  Widget build(BuildContext context) {
    TrackingData trackingData = Provider.of<TrackingData>(context);

    if(trackingData != null){
      updateCamera(trackingData);
      //updateMarkerAndCircle(trackingData);
    }


    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initialLocation,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }

}