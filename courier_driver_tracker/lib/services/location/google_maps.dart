import 'package:courier_driver_tracker/services/location/delivery.dart';
import 'package:courier_driver_tracker/services/location/geolocator_service.dart';
import 'package:courier_driver_tracker/services/location/route_logging.dart';
import 'package:courier_driver_tracker/services/navigation/navigator_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  List<LatLng> polylineCoordinates = [];
  Map<String, Polyline> polylines = {};

  //Location service
  GeolocatorService _geolocatorService = GeolocatorService();
  Position _currentPosition;

  // Deliveries
  List<Position> deliveries = [
    new Position(latitude: -25.7815, longitude: 28.2759),
    new Position(latitude: -25.7597, longitude: 28.2436),
    new Position(latitude: -25.7545, longitude: 28.2314),
    new Position(latitude: -25.7608, longitude: 28.2310),
    new Position(latitude: -25.7713, longitude: 28.2334)
  ];
  String _currentDelivery = 'Loading';
  Deliveries polyDeliveries;
  List<Delivery> deliveryList;
  
  // Storage
  RouteLogging _routeLogging = RouteLogging();

  // Navigation
  int _route;
  NavigatorService _navigatorService = NavigatorService();


  @override
  void initState() {
    super.initState();
    getRoutes();
    getCurrentLocation();
    getCurrentRoute();
  }


  /*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: none
   * Description: Sets current location and Google maps polylines if not set.
   */
  getCurrentLocation() async {
    _currentPosition = await _geolocatorService.getPosition();
    moveToCurrentLocation();
  }

  getRoutes() async {
    await _navigatorService.getRoutes();
  }

  getCurrentRoute(){
    _route = String.fromEnvironment('CURRENT_ROUTE', defaultValue: DotEnv().env['CURRENT_ROUTE']) as int;
  }

  /*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: none
   * Description: Moves Google map camera to current location.
   */
  moveToCurrentLocation(){
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
    ).catchError((e){
      print("Failed to move camera: " + e.toString());
    });
  }


  /*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: none
   * Description: Moves Google map camera to show entire route.
   */
  showEntireRoute(){
    // Define two position variables
    Position _northeastCoordinates;
    Position _southwestCoordinates;

    // Calculating to check that
    // southwest coordinate <= northeast coordinate
    // Determines the screen bounds
    double minLat = deliveries[0].latitude;
    double minLong = deliveries[0].longitude;
    double maxLat = deliveries[0].latitude;
    double maxLong = deliveries[0].longitude;

    for(int del = 0; del < deliveries.length; del++){
      if (minLat > deliveries[del].latitude) {
        minLat = deliveries[del].latitude;
      }
      if(minLong > deliveries[del].longitude){
        minLong = deliveries[del].longitude;
      }
      if (maxLat < deliveries[del].latitude) {
        maxLat = deliveries[del].latitude;
      }
      if(maxLong < deliveries[del].longitude){
        maxLong = deliveries[del].longitude;
      }
    }

    _southwestCoordinates = new Position(latitude: minLat, longitude: minLong);
    _northeastCoordinates = new Position(latitude: maxLat, longitude: maxLong);

    LatLngBounds routeBounds = new LatLngBounds(
      northeast: LatLng(
        _northeastCoordinates.latitude,
        _northeastCoordinates.longitude,
      ),
      southwest: LatLng(
        _southwestCoordinates.latitude,
        _southwestCoordinates.longitude,
      ),
    );

    // Center of route
    final LatLng routeCenter = LatLng(
        (routeBounds.northeast.latitude + routeBounds.southwest.latitude)/2,
        (routeBounds.northeast.longitude + routeBounds.southwest.longitude)/2
    );

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
  Future<void> zoomToFit(GoogleMapController controller, LatLngBounds bounds, LatLng centerBounds) async {
    bool keepZooming = true;
    final double zoomLevel = await controller.getZoomLevel();
    controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: centerBounds,
      zoom: zoomLevel,
    )));
    while(keepZooming) {
      final LatLngBounds screenBounds = await controller.getVisibleRegion();
      if(!zoom(bounds, screenBounds)){
        keepZooming = false;
        break;
      }

      if(zoomIn(bounds, screenBounds)){
        final double zoomLevel = await controller.getZoomLevel() + 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
      }
      else {
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
  bool zoom(LatLngBounds markerBounds, LatLngBounds screenBounds){
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= markerBounds.northeast.latitude + 0.005
                                      && screenBounds.northeast.latitude <= markerBounds.northeast.latitude + 0.04;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= markerBounds.northeast.longitude + 0.005
                                      && screenBounds.northeast.longitude <= markerBounds.northeast.longitude + 0.04;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= markerBounds.southwest.latitude - 0.015
                                      && screenBounds.southwest.latitude >= markerBounds.southwest.latitude - 0.04;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= markerBounds.southwest.longitude - 0.005
                                      && screenBounds.southwest.longitude >= markerBounds.southwest.longitude - 0.04;

    return !(northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck);
  }

  bool zoomIn(LatLngBounds markerBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= markerBounds.northeast.latitude + 0.01;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= markerBounds.northeast.longitude + 0.01;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= markerBounds.southwest.latitude - 0.02;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= markerBounds.southwest.longitude - 0.01;

    return northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck;
  }


  /*
   * Author: Gian Geyser
   * Parameters: none
   * Returns: none
   * Description: Gets the address of the delivery using coordinates.
   */
  getNextDelivery(Position position) async {
    String address = await _geolocatorService.getAddress(position);
    setState(() {
      _currentDelivery = address;
    });
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
    _navigatorService.setInitialPolyPointsAndMarkers(_route);
    polylines = _navigatorService.polylines;
    markers = _navigatorService.markers;
  }


  @override
  Widget build(BuildContext context) {
    // Stream of Position objects of current location.
    _currentPosition = Provider.of<Position>(context);

    // Calls abnormality service
    if(_currentPosition != null){
      _navigatorService.updateCurrentPosition(_currentPosition);
      _routeLogging.writeToFile(_geolocatorService.convertPositionToString(_currentPosition) + "\n", "locationFile");
    }

    // Google Map View
    return Container(
      color: Colors.black,
      child: Column(
                // Google map container with buttons stacked on top
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          color: Colors.black,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                            child: GoogleMap(
                              initialCameraPosition: _initialLocation,
                              markers: markers != null ? Set<Marker>.from(markers) : null,
                              polylines: Set<Polyline>.of(polylines.values),
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                              mapType: MapType.normal,
                              zoomGesturesEnabled: true,
                              zoomControlsEnabled: false,
                              onMapCreated: (GoogleMapController controller) {
                                mapController = controller;
                                _createRoute();
                              },
                            ),
                          ),
                        ),
                        // Design for current location button

                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0, right: 10.0),
                            child: ClipOval(
                              child: Material(
                                color: Colors.amber[600], // button color
                                child: InkWell(
                                  splashColor: Colors.white, // inkwell color
                                  child: SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: Icon(Icons.my_location),
                                  ),
                                  onTap: () {
                                    _currentPosition != null ? moveToCurrentLocation() : getCurrentLocation();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0, right: 100.0),
                            child: ClipOval(
                              child: Material(
                                color: Colors.amber[600], // button color
                                child: InkWell(
                                  splashColor: Colors.white, // inkwell color
                                  child: SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: Icon(Icons.explore),
                                  ),
                                  onTap: () {
                                    _currentPosition != null && deliveries.isNotEmpty ? showEntireRoute() : getCurrentLocation();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Show zoom buttons
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              ClipOval(
                                child: Material(
                                  color: Colors.white, // button color
                                  child: InkWell(
                                    splashColor: Colors.black, // inkwell color
                                    child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: Icon(Icons.add),
                                    ),
                                    onTap: () {
                                      mapController.animateCamera(
                                        CameraUpdate.zoomIn(),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 40.0),
                                child: ClipOval(
                                  child: Material(
                                    color: Colors.white, // button color
                                    child: InkWell(
                                      splashColor: Colors.black, // inkwell color
                                      child: SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: Icon(Icons.remove),
                                      ),
                                      onTap: () {
                                        mapController.animateCamera(
                                          CameraUpdate.zoomOut(),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,

                  // Card with current Delivery details.
                    child: Card(
                      child: ListTile(
                        title: Text(
                          'Delivery'
                        ),
                        subtitle: Text(
                          _currentDelivery,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
      ),
    );
  }

}