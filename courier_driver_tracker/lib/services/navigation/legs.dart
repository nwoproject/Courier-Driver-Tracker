import 'package:courier_driver_tracker/services/navigation/distance.dart';
import 'package:courier_driver_tracker/services/navigation/drive_duration.dart';
import 'package:courier_driver_tracker/services/navigation/location.dart';
import 'package:courier_driver_tracker/services/navigation/steps.dart';
import 'package:json_annotation/json_annotation.dart';

part 'legs.g.dart';

@JsonSerializable(explicitToJson: true)
class Legs{
  Distance distance;
  DriveDuration duration;
  String endAddress;
  Location endLocation;
  String startAddress;
  Location startLocation;
  List<Steps> steps;

  Legs({this.distance,this.steps, this.duration, this.endAddress, this.endLocation, this.startAddress, this.startLocation});
  factory Legs.fromJson(Map<String, dynamic> data) => _$LegsFromJson(data);
  Map<String, dynamic> toJson() => _$LegsToJson(this);
}