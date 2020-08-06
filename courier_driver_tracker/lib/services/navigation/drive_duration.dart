import 'package:json_annotation/json_annotation.dart';

part 'drive_duration.g.dart';

@JsonSerializable()
class DriveDuration{
  String text;
  int value;

  DriveDuration({this.value, this.text});
  factory DriveDuration.fromJson(Map<String, dynamic> data) => _$DriveDurationFromJson(data);
  Map<String, dynamic> toJson() => _$DriveDurationToJson(this);
}