import 'package:courier_driver_tracker/services/location/geolocator_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GMap extends StatefulWidget {
  @override
  State<GMap> createState() => MapSampleState();
}

class MapSampleState extends State<GMap> {

  // Google map setup
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  GoogleMapController mapController;

  //Location service
  GeolocatorService _geolocatorService = GeolocatorService();
  Position _currentPosition;

  // Deliveries and Markers
  Set<Marker> markers = {};
  List<Position> deliveries = [
    new Position(latitude: -25.7600, longitude: 28.2437)
  ];
  String _currentDelivery = 'Loading';

  // Route PolylinePoints
  PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  getCurrentLocation() async {
    _currentPosition = await _geolocatorService.getPosition();
    moveToCurrentLocation();
    getNextDelivery(_currentPosition);
    // _createPolylines(_currentPosition, deliveries[0]);
  }

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
        ),
      ),
    ).catchError((e){
      print("Failed to move camera: " + e.toString());
    });
  }

  showEntireRoute(){
    // Define two position variables
    Position _northeastCoordinates;
    Position _southwestCoordinates;

// Calculating to check that
// southwest coordinate <= northeast coordinate
    if (_currentPosition.latitude <= deliveries[0].latitude) {
      _southwestCoordinates = _currentPosition;
      _northeastCoordinates = deliveries[0];
    } else {
      _southwestCoordinates = deliveries[0];
      _northeastCoordinates = _currentPosition;
    }

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

    final LatLng routeCenter = LatLng(
        (routeBounds.northeast.latitude + routeBounds.southwest.latitude)/2,
        (routeBounds.northeast.longitude + routeBounds.southwest.longitude)/2
    );

    // Accommodate the two locations within the
    // camera view of the map
    zoomToFit(mapController, routeBounds, routeCenter);

  }

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

  bool zoom(LatLngBounds markerBounds, LatLngBounds screenBounds){
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= markerBounds.northeast.latitude + 0.005
                                      && screenBounds.northeast.latitude <= markerBounds.northeast.latitude + 0.05;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= markerBounds.northeast.longitude + 0.005
                                      && screenBounds.northeast.longitude <= markerBounds.northeast.longitude + 0.05;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= markerBounds.southwest.latitude - 0.015
                                      && screenBounds.southwest.latitude >= markerBounds.southwest.latitude - 0.05;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= markerBounds.southwest.longitude - 0.005
                                      && screenBounds.southwest.longitude >= markerBounds.southwest.longitude - 0.05;

    return !(northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck);
  }

  bool zoomIn(LatLngBounds markerBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= markerBounds.northeast.latitude + 0.01;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= markerBounds.northeast.longitude + 0.01;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= markerBounds.southwest.latitude - 0.02;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= markerBounds.southwest.longitude - 0.01;

    return northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck;
  }

  getNextDelivery(Position position) async {
    String address = await _geolocatorService.getAddress(position);
    setState(() {
      _currentDelivery = address;
    });
  }

  addMarkers(List<Position> positions) async {
    for(Position position in positions){
      Marker marker = Marker(
        markerId: MarkerId('$position'),
        position: LatLng(
          position.latitude,
          position.longitude,
        ),
        infoWindow: InfoWindow(
        title: 'Coffee Break',
        snippet: await getNextDelivery(position),
        ),
        icon: BitmapDescriptor.defaultMarker,
      );
      markers.add(marker);
    }
  }

  _createPolylines(Position start, Position destination) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      String.fromEnvironment('APP_MAP_API_KEY', defaultValue: DotEnv().env['APP_MAP_API_KEY']), // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.transit,
    );
    print("Result: " + result.points.length.toString());

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    // Adding the polyline to the map
    polylines[id] = polyline;
  }

  _createRoute(){
    for(int position = 0; position < deliveries.length; position++){
      if(position == 0){
        _createPolylines(_currentPosition, deliveries[position]);
        _createPolylines(deliveries[position], deliveries[position + 1]);
      }
      else if(position == deliveries.length -1){
        _createPolylines(deliveries[position], deliveries[0]);
      }
      else{
        _createPolylines(deliveries[position], deliveries[position + 1]);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    _currentPosition = Provider.of<Position>(context);


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
                                addMarkers(deliveries);
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