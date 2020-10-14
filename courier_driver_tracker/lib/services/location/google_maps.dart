import 'package:courier_driver_tracker/services/location/geolocator_service.dart';
import 'package:courier_driver_tracker/services/file_handling/route_logging.dart';
import 'package:courier_driver_tracker/services/navigation/navigation_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class GMap extends StatefulWidget {
  @override
  State<GMap> createState() => MapSampleState();
}

class MapSampleState extends State<GMap> {
  // Google map setup
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  GoogleMapController mapController;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  Map<String, Polyline> _polylines = {};
  bool lockedOnPosition = true;

  List<Widget> _deliveries = [];
  List<Widget> _deliveries1 = [];

  //Location service
  GeolocatorService _geolocatorService = GeolocatorService();
  Position _currentPosition;

  // Storage
  RouteLogging _routeLogging = RouteLogging();

  // Navigation
  int _route;
  NavigationService _navigatorService = NavigationService();
  String _directions = "LOADING...";
  String _stepTimeRemaining = "LOADING...";
  String _distance = "";
  String _eta = "";
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
    _navigatorService.subscribe(this);
  }

  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  final headingLabelStyle = TextStyle(
    fontSize: 20,
    fontFamily: 'Montserrat',
  );

  Widget _deliveryCards(String text) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: ListTile(
          title: Text(
            text,
            style: headingLabelStyle,
          ),
        ),
      ),
    );
  }

  /*
   * Parameters: none
   * Returns: none
   * Description: Sets current location and Google maps polylines if not set.
   */
  getCurrentLocation() async {
    _currentPosition = await _geolocatorService.getPosition();
    if (_currentPosition != null) {
      moveToCurrentLocation();
    }
  }

  getCurrentRoute() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String currentRoute = await storage.read(key: 'current_route');
    if (_route == -1 && currentRoute != null) {
      _route = int.parse(currentRoute);
    }
  }

  setDirection(String directions) {
    _directions = directions;
  }

  setTimeRemaining(String deliveryTimeRemaining) {
    _stepTimeRemaining = deliveryTimeRemaining;
  }

  setDistance(String distance) {
    _distance = distance;
  }

  setETA(String eta) {
    _eta = eta;
  }

  setDelivery(String delivery) {
    _delivery = delivery;
  }

  setDeliveryAddress(String deliveryAddress) {
    _deliveryAddress = deliveryAddress;
  }

  setDirectionIconPath(String directionIconPath) {
    _directionIconPath = directionIconPath;
  }

  setPolylines(Map<String, Polyline> poly) {
    _polylines = poly;
  }

  setCircles(Set<Circle> circles) {
    _circles = circles;
  }

  setMarkers(Set<Marker> markers) {
    _markers = markers;
  }

  /*
   * Parameters: none
   * Returns: none
   * Description: Moves Google map camera to current location.
   */
  moveToCurrentLocation() {
    // Move camera to the specified latitude & longitude
    if(_currentPosition == null || mapController == null){
      return;
    }
    mapController
        .animateCamera(
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
    )
        .catchError((e) {
      print("Failed to move camera: " + e.toString());
    });
  }

  /*
   * Parameters: none
   * Returns: none
   * Description: Moves Google map camera to show entire route.
   */
  showEntireRoute() {
    // Define two position variables
    LatLng northEast = _navigatorService.northEast;
    LatLng southWest = _navigatorService.southWest;

    if (northEast == null || southWest == null) {
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
   * Parameters: none
   * Returns: none
   * Description: Moves Google map camera to current location
   */
  bool zoom(LatLngBounds markerBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >=
            markerBounds.northeast.latitude + 0.005 &&
        screenBounds.northeast.latitude <=
            markerBounds.northeast.latitude + 0.05;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >=
            markerBounds.northeast.longitude + 0.005 &&
        screenBounds.northeast.longitude <=
            markerBounds.northeast.longitude + 0.05;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <=
            markerBounds.southwest.latitude - 0.015 &&
        screenBounds.southwest.latitude >=
            markerBounds.southwest.latitude - 0.05;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <=
            markerBounds.southwest.longitude - 0.005 &&
        screenBounds.southwest.longitude >=
            markerBounds.southwest.longitude - 0.05;

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

  /*
   * Parameters: none
   * Returns: none
   * Description: Creates the whole routes polylines and sets markers.
   */
  _createRoute() async {
    /*TODO
      - make new function to replace polylines.
     */
    await _navigatorService.initialisePolyPointsAndMarkers(_route);
    _markers = _navigatorService.markers;
  }

  _updatePolyline() {
    _route = _navigatorService.getRoute();
    if (_route != null &&
        _route >= 0 &&
        _navigatorService.currentPolyline != null &&
        _navigatorService.polylines["$_route"] != null) {
      _polylines = {
        "current": _navigatorService.currentPolyline,
        "$_route": _navigatorService.polylines["$_route"]
      };
    }
  }

  setDeliveries() {
    int number = _navigatorService.getNumberOfDeliveries();

    for (int x = 0; x < number; x++) {
      setState(() {
        _deliveries1
            .add(_deliveryCards(_navigatorService.getDeliveryAddress(x)));
        _deliveries = _deliveries1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Stream of Position objects of current location.
    _currentPosition = Provider.of<Position>(context);
    var html = """<h3 style='color:white;'>$_directions</h3>""";
    double fontSize = MediaQuery.of(context).size.height * 0.027;

    // Calls abnormality service
    if (_currentPosition != null) {
      _navigatorService.navigate(_currentPosition, context);
      _routeLogging.writeToFile(
          _currentPosition.toString() + "\n", "locationFile");
      setDeliveries();

      _updatePolyline();
      if (lockedOnPosition) {
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
      color: Colors.white,
      panel: Center(
        child: Container(
          padding: EdgeInsets.all(10),
          child:
              ListView(padding: const EdgeInsets.all(5), children: _deliveries),
        ),
      ),
      collapsed: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: radius),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10.0, left: 10.0, right: 10),
                    child: Center(
                      child: Text(atDelivery ? "Arrived" : _stepTimeRemaining,
                          style: TextStyle(
                              color: Colors.green,
                              fontFamily: "Montserrat",
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10.0, left: 10.0, right: 10),
                    child: Center(
                      child: Text(
                          atDelivery ? "at Destination" : "$_distance . $_eta",
                          style: TextStyle(
                              color: Colors.grey,
                              fontFamily: "Montserrat",
                              fontSize: fontSize - 5)),
                    ),
                  ),
                ],
              ),
              VerticalDivider(
                  width: 20.0,
                  color: Colors.grey,
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
              ),


              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
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
                      padding: const EdgeInsets.only(top: 10.0),
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
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: Container(
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
                          markers: _markers != null
                              ? Set<Marker>.from(_markers)
                              : null,
                          polylines: Set<Polyline>.of(_polylines.values),
                          circles: _circles != null
                              ? Set<Circle>.from(_circles)
                              : null,
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
                                    leading: Image(
                                      image: AssetImage(_directionIconPath),
                                      height: 40,
                                    ),
                                    title: new HtmlWidget(html),
                                  )
                                ],
                              ),
                            )),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 110.0, right: 10.0),
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
                          padding:
                              const EdgeInsets.only(top: 180.0, right: 10.0),
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
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 200.0),
                          child: Container(
                            child: atDelivery
                                ? RaisedButton(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12.0, horizontal: 40.0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        side: BorderSide(
                                            color: Colors.green, width: 3.0)),
                                    child: Text(
                                      "FINISH DELIVERY",
                                      style: TextStyle(
                                          fontSize: 30.0,
                                          color: Colors.white,
                                          fontFamily: "Montserrat"),
                                    ),
                                    color: Colors.green,
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushNamed("/reportDelivery");
                                      _navigatorService.moveToNextDelivery();
                                    },
                                  )
                                : Container(),
                          ),
                        ),
                      ),
                      // Show zoom buttons
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
      borderRadius: radius,
    );
  }
}
