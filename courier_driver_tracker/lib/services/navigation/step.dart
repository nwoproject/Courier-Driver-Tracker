import 'package:courier_driver_tracker/services/navigation/location.dart';
import 'package:courier_driver_tracker/services/navigation/overview_polyline.dart';
import 'package:json_annotation/json_annotation.dart';

part 'step.g.dart';

@JsonSerializable(explicitToJson: true)
class Step{
  int distance;
  int duration;
  Location endLocation;
  String htmlInstructions;
  String maneuver;
  OverviewPolyline polyline;
  Location startLocation;

  Step({this.startLocation, this.endLocation, this.duration, this.distance, this.polyline, this.htmlInstructions, this.maneuver});
  factory Step.fromJson(Map<String, dynamic> data) => _$StepFromJson(data);
  Map<String, dynamic> toJson() => _$StepToJson(this);

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