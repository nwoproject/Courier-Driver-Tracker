import 'package:json_annotation/json_annotation.dart';

part 'distance.g.dart';

@JsonSerializable()
class Distance{
  String text;
  int value;

  Distance({this.text, this.value});
  factory Distance.fromJson(Map<String, dynamic> data) => _$DistanceFromJson(data);
  Map<String, dynamic> toJson() => _$DistanceToJson(this);
}