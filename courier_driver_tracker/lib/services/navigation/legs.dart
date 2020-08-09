import 'package:courier_driver_tracker/services/navigation/location.dart';
import 'package:courier_driver_tracker/services/navigation/steps.dart';
import 'package:json_annotation/json_annotation.dart';

part 'legs.g.dart';

@JsonSerializable(explicitToJson: true)
class Legs{
  int distance;
  int duration;
  String endAddress;
  Location endLocation;
  String startAddress;
  Location startLocation;
  List<Steps> steps;

  Legs({this.distance,this.steps, this.duration, this.endAddress, this.endLocation, this.startAddress, this.startLocation});
  factory Legs.fromJson(Map<String, dynamic> data) => _$LegsFromJson(data);
  Map<String, dynamic> toJson() => _$LegsToJson(this);
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
}