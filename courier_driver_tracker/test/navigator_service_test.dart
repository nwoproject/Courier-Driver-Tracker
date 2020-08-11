import 'package:courier_driver_tracker/services/navigation/delivery_route.dart';
import 'package:courier_driver_tracker/services/navigation/route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:courier_driver_tracker/services/navigation/navigator_service.dart';
import 'package:courier_driver_tracker/services/file_handling/json_handler.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  String filename = "route.json";
  Map<String, dynamic> json = await JsonHandler().parseJson(filename);
  NavigatorService navigatorService;

  test("Initialisation Test",() async {
    bool created;
    navigatorService = NavigatorService(jsonFile: filename);

    if(navigatorService is NavigatorService){
      created  = true;
    }
    else{
      created = false;
    }
    expect(created, true);
  });

  test("DeliveryRoute Test",() async {
    if(navigatorService == null){
      navigatorService = NavigatorService(jsonFile: filename);
      await navigatorService.getRoutes();
    }
    bool created;

    if(navigatorService.getDeliveryRoute() is DeliveryRoute){
      created  = true;
    }
    else{
      created = false;
    }
    expect(created, true);
  });

  test("getDirection Test",() async {
    if(navigatorService == null){
      navigatorService = NavigatorService(jsonFile: filename);
      await navigatorService.getRoutes();
    }
    String direction = navigatorService.getDirection();
    expect(direction, json["routes"][navigatorService.getDelivery()]["legs"][navigatorService.getLeg()]["steps"][navigatorService.getStep()]["html_instructions"]);
  });

  test("getNextDirection Test",() async {
    if(navigatorService == null){
      navigatorService = NavigatorService(jsonFile: filename);
      await navigatorService.getRoutes();
    }
    String direction = navigatorService.getNextDirection();
    expect(direction, json["routes"][navigatorService.getDelivery()]["legs"][navigatorService.getLeg()]["steps"][navigatorService.getStep() + 1]["html_instructions"]);
  });

  test("getArrivalTime Test",() async {
    if(navigatorService == null){
      navigatorService = NavigatorService(jsonFile: filename);
      await navigatorService.getRoutes();
    }
    int direction = navigatorService.getArrivalTime();
    expect(direction, json["routes"][navigatorService.getDelivery()]["legs"][navigatorService.getLeg()]["steps"][navigatorService.getStep()]["duration"]);
  });

  test("getDistance Test",() async {
    if(navigatorService == null){
      navigatorService = NavigatorService(jsonFile: filename);
      await navigatorService.getRoutes();
    }
    int direction = navigatorService.getDistance();
    expect(direction, json["routes"][navigatorService.getDelivery()]["legs"][navigatorService.getLeg()]["steps"][navigatorService.getStep()]["distance"]);
  });

  test("getDeliveryArrivalTime Test",() async {
    if(navigatorService == null){
      navigatorService = NavigatorService(jsonFile: filename);
      await navigatorService.getRoutes();
    }
    int direction = navigatorService.getDeliveryArrivalTime();
    expect(direction, json["routes"][navigatorService.getDelivery()]["legs"][navigatorService.getLeg()]["duration"]);
  });

  test("getDeliveryDistance Test",() async {
    if(navigatorService == null){
      navigatorService = NavigatorService(jsonFile: filename);
      await navigatorService.getRoutes();
    }
    int direction = navigatorService.getDeliveryDistance();
    expect(direction, json["routes"][navigatorService.getDelivery()]["legs"][navigatorService.getLeg()]["distance"]);
  });

  test("See if polylines and markers are made correctly", () async {
    if(navigatorService == null){
      navigatorService = NavigatorService(jsonFile: filename);
      await navigatorService.getRoutes();
    }

    navigatorService.setInitialPolyPointsAndMarkers(navigatorService.getDelivery());

    DeliveryRoute routes = navigatorService.getDeliveryRoute();
    int delivery = navigatorService.getDelivery();
    bool markersCorrect;
    bool polysCorrect;
    int numPolys = 0;

    for(int leg = 0; leg < routes.routes[delivery].legs.length; leg++){
      for(int step = 0; step < routes.routes[delivery].legs[leg].steps.length; step++){
        numPolys += 1;
      }
    }

    if(navigatorService.markers.length == routes.routes[delivery].legs.length){
      markersCorrect = true;
    }
    else{
      markersCorrect = false;
    }

    if(navigatorService.polylines.length == numPolys){
      polysCorrect = true;
    }
    else{
      polysCorrect = false;
    }

    expect((markersCorrect && polysCorrect), true);


  });


}