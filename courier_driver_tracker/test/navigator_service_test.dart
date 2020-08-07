import 'package:courier_driver_tracker/services/navigation/delivery_route.dart';
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
    expect(direction, json["routes"][navigatorService.getDelivery()]["legs"][navigatorService.getLeg()]["steps"][navigatorService.getStep()]["duration"]["value"]);
  });

  test("getDistance Test",() async {
    if(navigatorService == null){
      navigatorService = NavigatorService(jsonFile: filename);
      await navigatorService.getRoutes();
    }
    int direction = navigatorService.getDistance();
    expect(direction, json["routes"][navigatorService.getDelivery()]["legs"][navigatorService.getLeg()]["steps"][navigatorService.getStep()]["distance"]["value"]);
  });

  test("getDeliveryArrivalTime Test",() async {
    if(navigatorService == null){
      navigatorService = NavigatorService(jsonFile: filename);
      await navigatorService.getRoutes();
    }
    int direction = navigatorService.getDeliveryArrivalTime();
    expect(direction, json["routes"][navigatorService.getDelivery()]["legs"][navigatorService.getLeg()]["duration"]["value"]);
  });

  test("getDeliveryDistance Test",() async {
    if(navigatorService == null){
      navigatorService = NavigatorService(jsonFile: filename);
      await navigatorService.getRoutes();
    }
    int direction = navigatorService.getDeliveryDistance();
    expect(direction, json["routes"][navigatorService.getDelivery()]["legs"][navigatorService.getLeg()]["distance"]["value"]);
  });


}