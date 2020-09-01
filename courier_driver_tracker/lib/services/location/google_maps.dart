import 'package:courier_driver_tracker/services/location/delivery.dart';
import 'package:courier_driver_tracker/services/location/geolocator_service.dart';
import 'file:///D:/COS/COS301/CapstoneProject/Courier-Driver-Tracker/Courier-Driver-Tracker/courier_driver_tracker/lib/services/file_handling/route_logging.dart';
import 'package:courier_driver_tracker/services/navigation/navigation_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import 'deliveries.dart';

class GMap extends StatefulWidget {
  @override
  State<GMap> createState() => MapSampleState();
}

class MapSampleState extends State<GMap> {
  // Google map setup
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  GoogleMapController mapController;
  Set<Marker> markers = {};
  Set<Circle>  circles = {};
  List<LatLng> polylineCoordinates = [];
  Map<String, Polyline> polylines = {};
  bool lockedOnPosition = true;

  //Location service
  GeolocatorService _geolocatorService = GeolocatorService();
  Position _currentPosition;

  // Storage
  RouteLogging _routeLogging = RouteLogging();

  // Navigation
  int _route;
  static String _routeFile = "route.json";
  NavigationService _navigatorService = NavigationService(jsonFile: _routeFile);
  String _directions = "LOADING...";
  String _stepTimeRemaining = "LOADING...";
  String _distanceETA = "";
  String _delivery = "LOADING...";
  String _deliveryAddress = "";
  String _directionIconPath = "assets/images/navigation_marker_white.png";
  bool atDelivery = false;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    getCurrentRoute();
    _createRoute();
    setInformationVariables();
  }

  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  final headingLabelStyle = TextStyle(
    fontSize: 20,
    fontFamily: 'OpenSans-Regular',
  );

  Widget _deliveryCards(String text, String date) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: ListTile(
          title: Text(
            text,
            style: headingLabelStyle,
          ),
          subtitle: Text(
            date,
          ),
        ),
      ),
    );
  }

  /*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: none
   * Description: Sets current location and Google maps polylines if not set.
   */
  getCurrentLocation() async {
    _currentPosition = await _geolocatorService.getPosition();
    if(_currentPosition != null){
      moveToCurrentLocation();
    }
  }

  getCurrentRoute(){
    String currentRoute = String.fromEnvironment('CURRENT_ROUTE', defaultValue: DotEnv().env['CURRENT_ROUTE']);
    _route = int.parse(currentRoute);
  }

  /*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: none
   * Description: Moves Google map camera to current location.
   */
  moveToCurrentLocation() {
    // Move camera to the specified latitude & longitude
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            // Will be fetching in the next step
            _currentPosition.latitude,
            _currentPosition.longitude,
          ),
          zoom: 18.0,
          bearing: _currentPosition.heading,
        ),
      ),
    ).catchError((e) {
      print("Failed to move camera: " + e.toString());
    });
  }

  /*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: none
   * Description: Moves Google map camera to show entire route.
   */
  showEntireRoute() {
    // Define two position variables
    LatLng northEast = _navigatorService.northEast;
    LatLng southWest = _navigatorService.southWest;

    if(northEast == null || southWest == null){
      return;
    }

    LatLngBounds routeBounds = new LatLngBounds(
      northeast: northEast,
      southwest: southWest,
    );

    // Center of route
    final LatLng routeCenter = LatLng(
        (routeBounds.northeast.latitude + routeBounds.southwest.latitude) / 2,
        (routeBounds.northeast.longitude + routeBounds.southwest.longitude) /
            2);

    // Accommodate the two locations within the
    // camera view of the map
    zoomToFit(mapController, routeBounds, routeCenter);
  }

  /*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: none
   * Description: Zooms in or out on Google map camera to show route within screen bounds.
   */
  Future<void> zoomToFit(GoogleMapController controller, LatLngBounds bounds,
      LatLng centerBounds) async {
    bool keepZooming = true;
    final double zoomLevel = await controller.getZoomLevel();
    controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: centerBounds,
      zoom: zoomLevel,
    )));
    while (keepZooming) {
      final LatLngBounds screenBounds = await controller.getVisibleRegion();
      if (!zoom(bounds, screenBounds)) {
        keepZooming = false;
        break;
      }

      if (zoomIn(bounds, screenBounds)) {
        final double zoomLevel = await controller.getZoomLevel() + 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
      } else {
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
      }
    }
  }

  /*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: none
   * Description: Moves Google map camera to current location
   */
  bool zoom(LatLngBounds markerBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >=
            markerBounds.northeast.latitude + 0.005 &&
        screenBounds.northeast.latitude <=
            markerBounds.northeast.latitude + 0.04;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >=
            markerBounds.northeast.longitude + 0.005 &&
        screenBounds.northeast.longitude <=
            markerBounds.northeast.longitude + 0.04;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <=
            markerBounds.southwest.latitude - 0.015 &&
        screenBounds.southwest.latitude >=
            markerBounds.southwest.latitude - 0.04;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <=
            markerBounds.southwest.longitude - 0.005 &&
        screenBounds.southwest.longitude >=
            markerBounds.southwest.longitude - 0.04;

    return !(northEastLatitudeCheck &&
        northEastLongitudeCheck &&
        southWestLatitudeCheck &&
        southWestLongitudeCheck);
  }

  bool zoomIn(LatLngBounds markerBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >=
        markerBounds.northeast.latitude + 0.01;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >=
        markerBounds.northeast.longitude + 0.01;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <=
        markerBounds.southwest.latitude - 0.02;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <=
        markerBounds.southwest.longitude - 0.01;

    return northEastLatitudeCheck &&
        northEastLongitudeCheck &&
        southWestLatitudeCheck &&
        southWestLongitudeCheck;
  }

  setInformationVariables(){
    if(_navigatorService.directions != null){
      _directions = _navigatorService.directions;
    }
    if(_navigatorService.deliveryTimeRemaining != null){
      _stepTimeRemaining = _navigatorService.deliveryTimeRemaining;
    }
    if(_navigatorService.distanceETA != null){
      _distanceETA = _navigatorService.distanceETA;
    }
    if(_navigatorService.delivery != null){
      _delivery = _navigatorService.delivery;
    }
    if(_navigatorService.deliveryAddress != null){
      _deliveryAddress = _navigatorService.deliveryAddress;
    }
    if(_navigatorService.directionIconPath != null){
      _directionIconPath = _navigatorService.directionIconPath;
    }
    circles = _navigatorService.circles;
    atDelivery = _navigatorService.atDelivery;
  }

  /*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: none
   * Description: Creates the whole routes polylines and sets markers.
   */
  _createRoute() async {
    /*TODO
      - make new function to replace polylines.
     */
    await _navigatorService.initialisePolyPointsAndMarkers(_route);
    polylines = _navigatorService.polylines;
    markers = _navigatorService.markers;
  }

  @override
  Widget build(BuildContext context) {
    // Stream of Position objects of current location.
    _currentPosition = Provider.of<Position>(context);
    var html = """<h3 style='color:white;'>$_directions</h3>""";
    double fontSize = MediaQuery.of(context).size.height * 0.027;

    // Calls abnormality service
    if(_currentPosition != null) {
      _routeLogging.writeToFile(_currentPosition.toJson().toString(), "locationFile");
      _navigatorService.navigate(_currentPosition, context);
      setInformationVariables();
      if(lockedOnPosition){
        moveToCurrentLocation();
      }
    }

    BoxDecoration myBoxDecoration() {
      return BoxDecoration(
          borderRadius: BorderRadius.all(
              Radius.circular(30) //         <--- border radius here
              ),
          boxShadow: [
            BoxShadow(
                color: Colors.grey,
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3))
          ]);
    }

    // Google Map View
    return SlidingUpPanel(
      color: Color.fromARGB(255, 58, 52, 64),
      panel: Center(
        child: Container(
          padding: EdgeInsets.all(10),
          child: ListView(
            padding: const EdgeInsets.all(5),
            children: <Widget>[
              _deliveryCards("Menlyn Park Shopping Centre",
                  "01-25-2020 12:00"),
              _deliveryCards(
                  "Aroma Gourmet Coffee Roastery", "01-25-2020 13:00"),
              _deliveryCards("University of Pretoria", "01-25-2020 13:45"),
              _deliveryCards(
                  "Pretoria High School for boys", "01-25-2020 14:00"),
            ],
          ),
        ),
      ),
      collapsed: Container(
        decoration:
        BoxDecoration(color: Colors.white, borderRadius: radius),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, left: 10.0, right: 10),
                    child: Center(
                      child: Text(atDelivery ? "Arrived" : _stepTimeRemaining,
                          style: TextStyle(
                              color: Colors.green,
                              fontFamily: "OpenSans-Regular",
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, left: 10.0, right: 10),
                    child: Center(
                      child: Text(atDelivery ? "at Destination" :_distanceETA,
                          style: TextStyle(
                              color: Colors.grey,
                              fontFamily: "OpenSans-Regular",
                              fontSize: fontSize - 5)),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: VerticalDivider(
                  width: 10.0,
                  color: Colors.grey,
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                ),
              ),
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 15.0),
                    child: Center(
                      child: Text(_delivery,
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "OpenSans-Regular",
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 15.0),
                    child: Center(
                      child: Text(_deliveryAddress,
                          style: TextStyle(
                              color: Colors.grey,
                              fontFamily: "OpenSans-Regular",
                              fontSize: fontSize - 5)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: Container(
            child: Column(
              // Google map container with buttons stacked on top
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        child: GoogleMap(
                          initialCameraPosition: _initialLocation,
                          markers: markers != null ? Set<Marker>.from(markers) : null,
                          polylines: Set<Polyline>.of(polylines.values),
                          circles: circles != null ? Set<Circle>.from(circles) : null,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          mapType: MapType.normal,
                          zoomGesturesEnabled: true,
                          zoomControlsEnabled: false,
                          onMapCreated: (GoogleMapController controller) {
                            mapController = controller;
                          },
                        ),
                      ),
                      // Design for current location button
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                            padding: const EdgeInsets.only(
                                top: 20.0, left: 10.0, right: 10.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              color: Colors.green,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    leading: Image(image: AssetImage(_directionIconPath),
                                    height: 40,),
                                    title: new HtmlWidget(html),
                                  )
                                ],
                              ),
                            )),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 110.0, right: 10.0),
                          child: Container(
                            decoration: myBoxDecoration(),
                            child: ClipOval(
                              child: Material(
                                color: Colors.white, // button color
                                child: InkWell(
                                  splashColor: Colors.white, // inkwell color
                                  child: SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: Icon(Icons.my_location),
                                  ),
                                  onTap: () {
                                    _currentPosition != null
                                        ? moveToCurrentLocation()
                                        : getCurrentLocation();
                                    lockedOnPosition = true;
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 180.0, right: 10.0),
                          child: Container(
                            decoration: myBoxDecoration(),
                            child: ClipOval(
                              child: Material(
                                color: Colors.white, // button color
                                child: InkWell(
                                  splashColor: Colors.white, // inkwell color
                                  child: SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: Icon(Icons.explore),
                                  ),
                                  onTap: () {
                                    _currentPosition != null
                                        ? showEntireRoute()
                                        : getCurrentLocation();
                                    lockedOnPosition = false;
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Show zoom buttons
                    ],
                  ),
                ),
              ],
            ),
          )
          ),
        ],
      ),
      borderRadius: radius,
    );
  }
}
