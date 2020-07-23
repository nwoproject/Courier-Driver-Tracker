import 'package:courier_driver_tracker/services/location/route_logging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "dart:ui";

class DeliveryPage extends StatelessWidget{

  final headingLabelStyle = TextStyle(
    fontSize: 20,
    fontFamily: 'OpenSans-Regular',
  );

  RouteLogging routeLogging = RouteLogging();


  Future<String> getDeliveryDetails() async {
      routeLogging.writeToFile("hello this is working", "deliveryFile");

      String content = await routeLogging.readFileContents("deliveryFile");
      return content;

  }

  Widget _deliveryCards(String text, String date){
   return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical:10 , horizontal: 8),
        child: ListTile(
          title: Text(
            text,
            style: headingLabelStyle,
            ),
          subtitle: Text(
            date,
          ),
          ),
        )
      );
  }



  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.black,
        title: new Text("Deliveries"),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: ListView(
          padding: const EdgeInsets.all(5),
          children: <Widget>[
            _deliveryCards("Menlyn Park Shopping Centre","01-25-2020 12:00"),                       //mock data
            _deliveryCards("Aroma Gourmet Coffee Roastery", "01-25-2020 13:00"),
            _deliveryCards("University of Pretoria", "01-25-2020 13:45"),
            _deliveryCards("Pretoria High School for boys", "01-25-2020 14:00"),
          ],
        )


        ),
      );
  }
}


