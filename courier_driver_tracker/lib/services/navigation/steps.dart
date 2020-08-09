import 'package:courier_driver_tracker/services/navigation/location.dart';
import 'package:courier_driver_tracker/services/navigation/overview_polyline.dart';
import 'package:json_annotation/json_annotation.dart';

part 'steps.g.dart';

@JsonSerializable(explicitToJson: true)
class Steps{
  int distance;
  int duration;
  Location endLocation;
  String htmlInstructions;
  String maneuver;
  OverviewPolyline polyline;
  Location startLocation;

  Steps({this.startLocation, this.endLocation, this.duration, this.distance, this.polyline, this.htmlInstructions, this.maneuver});
  factory Steps.fromJson(Map<String, dynamic> data) => _$StepsFromJson(data);
  Map<String, dynamic> toJson() => _$StepsToJson(this);

  String getHTMLInstruction(){
    if(htmlInstructions == null){
      return "Straight";
    }
    return htmlInstructions;
  }

  String getManeuver(){
    return maneuver;
  }

  int getDuration(){
    return duration;
  }

  int getDistance(){
    return distance;
  }
}