import 'package:courier_driver_tracker/services/location/route_logging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "dart:ui";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DeliveryScreen extends StatefulWidget {
  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final headingLabelStyle = TextStyle(
      fontSize: 25, fontFamily: 'OpenSans-Regular', color: Colors.grey[300]);
  final headingLabelStyle2 = TextStyle(
      fontSize: 30, fontFamily: 'OpenSans-Regular', color: Colors.grey[100]);
  final textStyle = TextStyle(
      fontSize: 20, fontFamily: 'OpenSans-Regular', color: Colors.grey[100]);
  final RouteLogging routeLogging = RouteLogging();

  Future<String> getDeliveryDetails() async {
    routeLogging.writeToFile("hello this is working", "deliveryFile");

    String content = await routeLogging.readFileContents("deliveryFile");
    return content;
  }

  Widget _deliveryCards(String text, String distance, String time, String del) {
    return Card(
      color: Colors.grey[800],
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Center(
          child: ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(top: 16.0, right: 10.0),
              child: CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 25,
                  child: Icon(
                    FontAwesomeIcons.check,
                    color: Colors.grey[100],
                    size: 22,
                  )),
            ),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(
                text,
                style: headingLabelStyle,
              ),
            ),
            subtitle: Text(
              "$distance\n$time\n$del",
              style: textStyle,
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Icon(
                Icons.keyboard_arrow_right,
                color: Colors.grey[100],
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(15),
            bottomLeft: Radius.circular(15) //         <--- border radius here
            ),
        color: Colors.blue,
        boxShadow: [
          BoxShadow(
              color: Colors.grey[900],
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3))
        ]);
  }

  BoxDecoration tickBoxDecoration() {
    return BoxDecoration(
      color: Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        bottomNavigationBar: _buildBottomNavigationBar,
        backgroundColor: Colors.grey[900],
        body: SafeArea(
            child: Column(children: <Widget>[
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 7.0),
              child: Container(
                decoration: myBoxDecoration(),
                child: ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 3.0),
                    child: Text("Today's Routes", style: headingLabelStyle2),
                  ),
                  subtitle: RichText(
                      text: TextSpan(children: [
                    WidgetSpan(
                      child:
                          Icon(FontAwesomeIcons.road, color: Colors.grey[100]),
                    ),
                    TextSpan(text: "  Total KM : 30km\n", style: textStyle),
                    WidgetSpan(
                      child:
                          Icon(FontAwesomeIcons.clock, color: Colors.grey[100]),
                    ),
                    TextSpan(
                        text: "  Total time : 40Min\n\n", style: textStyle),
                    TextSpan(
                        text: "Current Route: Not Selected", style: textStyle)
                  ])),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: ListView(
              padding: const EdgeInsets.all(5),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: _deliveryCards("Route 1", "Distance: 15km",
                      "Time: 20 Min", "Deliveries: 3"),
                ), //mock data
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: _deliveryCards("Route 2", "Distance: 15km",
                      "Time: 20 Min", "Deliveries: 3"),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: _deliveryCards("Route 3", "Distance: 15km",
                      "Time: 20 Min", "Deliveries: 3"),
                ),
              ],
            ),
          ),
        ])));
  }

  Widget get _buildBottomNavigationBar {
    return ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
        child: BottomNavigationBar(
            backgroundColor: Colors.grey[800],
            unselectedItemColor: Colors.grey[100],
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.home, size: 30, color: Colors.blue),
                title: SizedBox(
                  width: 0,
                  height: 0,
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.mapMarkerAlt, size: 30),
                title: SizedBox(
                  width: 0,
                  height: 0,
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.userAlt, size: 30),
                title: SizedBox(
                  width: 0,
                  height: 0,
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.cog, size: 30),
                title: SizedBox(
                  width: 0,
                  height: 0,
                ),
              )
            ],
            onTap: (index) {
              if (index == 1) {
                Navigator.of(context).pop();
              } else if (index == 2) {
                Navigator.of(context).popAndPushNamed("/profile");
              } else if (index == 3) {
                Navigator.of(context).popAndPushNamed("/settings");
              }
            }));
  }
}
