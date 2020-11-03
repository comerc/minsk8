import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'proclamation.g.dart';

@JsonSerializable()
class ProclamationModel {
  ProclamationModel({
    this.id,
    this.unit,
    this.text,
  });

  final String id;
  @JsonKey(nullable: true)
  final UnitModel unit;
  final String text;

  factory ProclamationModel.fromJson(Map<String, dynamic> json) =>
      _$ProclamationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProclamationModelToJson(this);
}
