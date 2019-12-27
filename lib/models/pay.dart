import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'pay.g.dart';

@JsonSerializable()
class PayModel {
  final String id;
  final String text;
  final int value;

  PayModel(this.id, this.text, this.value);

  factory PayModel.fromJson(Map<String, dynamic> json) =>
      _$PayModelFromJson(json);

  Map<String, dynamic> toJson() => _$PayModelToJson(this);
}
