import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'give.g.dart';

@JsonSerializable()
class GiveModel {
  GiveModel({
    this.createdAt,
    this.unit,
  });

  final DateTime createdAt;
  UnitModel unit;

  factory GiveModel.fromJson(Map<String, dynamic> json) =>
      _$GiveModelFromJson(json);
}
