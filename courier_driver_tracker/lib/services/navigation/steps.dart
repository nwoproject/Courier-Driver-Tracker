import 'package:courier_driver_tracker/services/navigation/distance.dart';
import 'package:courier_driver_tracker/services/navigation/drive_duration.dart';
import 'package:courier_driver_tracker/services/navigation/location.dart';
import 'package:courier_driver_tracker/services/navigation/overview_polyline.dart';
import 'package:json_annotation/json_annotation.dart';

part 'steps.g.dart';

@JsonSerializable(explicitToJson: true)
class Steps{
  Distance distance;
  DriveDuration duration;
  Location endLocation;
  String htmlInstructions;
  String maneuver;
  OverviewPolyline polyline;
  Location startLocation;

  Steps({this.startLocation, this.endLocation, this.duration, this.distance, this.polyline, this.htmlInstructions, this.maneuver});
  factory Steps.fromJson(Map<String, dynamic> data) => _$StepsFromJson(data);
  Map<String, dynamic> toJson() => _$StepsToJson(this);

  String getHTMLInstruction(){
    return htmlInstructions;
  }

  String getManeuver(){
    return maneuver;
  }

  int getDuration(){
    return duration.value;
  }

  int getDistance(){
    return distance.value;
  }
}