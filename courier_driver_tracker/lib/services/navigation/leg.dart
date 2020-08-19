import 'package:courier_driver_tracker/services/navigation/location.dart';
import 'package:courier_driver_tracker/services/navigation/step.dart';
import 'package:json_annotation/json_annotation.dart';

part 'leg.g.dart';

@JsonSerializable(explicitToJson: true)
class Leg{
  int distance;
  int duration;
  String endAddress;
  Location endLocation;
  String startAddress;
  Location startLocation;
  List<Step> steps;

  Leg({this.distance,this.steps, this.duration, this.endAddress, this.endLocation, this.startAddress, this.startLocation});
  factory Leg.fromJson(Map<String, dynamic> data) => _$LegFromJson(data);
  Map<String, dynamic> toJson() => _$LegToJson(this);
  String getHTMLInstruction(int step){
    if(step >= steps.length){
      return "Delivery";
    }
    return steps[step].getHTMLInstruction();
  }

  String getManeuver(int step){
    return steps[step].getManeuver();
  }

  int getDuration(int step){
    return steps[step].getDuration();
  }

  int getDistance(int step){
    return steps[step].getDistance();
  }

  int getDeliveryDuration(){
    return duration;
  }

  int getDeliveryDistance(){
    return distance;
  }

  String getDeliveryAddress(){
    return endAddress;
  }
}