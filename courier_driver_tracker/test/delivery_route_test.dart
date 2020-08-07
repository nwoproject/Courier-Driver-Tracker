import 'package:flutter_test/flutter_test.dart';
import 'package:courier_driver_tracker/services/navigation/delivery_route.dart';
import 'package:courier_driver_tracker/services/file_handling/json_handler.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  test("Test to see if a object Path is created",() async {
    bool created;

    String filename = "route.json";
    Map<String, dynamic> json = await JsonHandler().parseJson(filename);
    //print(json);
    print("\u003c");
    DeliveryRoute deliveryRoute = DeliveryRoute.fromJson(json);

    if(deliveryRoute is DeliveryRoute){
      created  = true;
    }
    else{
      created = false;
    }
    expect(true, created);
  });

}