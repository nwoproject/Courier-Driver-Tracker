import 'package:courier_driver_tracker/services/navigation/bounds.dart';
import 'package:courier_driver_tracker/services/navigation/legs.dart';
import 'package:courier_driver_tracker/services/navigation/overview_polyline.dart';
import 'package:json_annotation/json_annotation.dart';

part 'routes.g.dart';

@JsonSerializable(explicitToJson: true)
class Routes{
  Bounds bounds;
  String copyrights;
  List<Legs> legs;
  OverviewPolyline overviewPolyline;
  String summary;
  List<String> warnings;
  List<String> waypointOrder;

  Routes({this.overviewPolyline, this.bounds, this.copyrights, this.legs, this.summary, this.warnings, this.waypointOrder});
  factory Routes.fromJson(Map<String, dynamic> data) => _$RoutesFromJson(data);
  Map<String, dynamic> toJson() => _$RoutesToJson(this);
  String getHTMLInstruction(int leg, int step){
    return legs[leg].getHTMLInstruction(step);
  }

  String getManeuver(int leg, int step){
    return legs[leg].getManeuver(step);
  }

  int getDuration(int leg, int step){
    return legs[leg].getDuration(step);
  }

  int getDistance(int leg, int step){
    return legs[leg].getDistance(step);
  }
}