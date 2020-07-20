import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'give.g.dart';

@JsonSerializable()
class GiveModel {
  GiveModel({
    this.createdAt,
    this.item,
  });

  final DateTime createdAt;
  ItemModel item;

  factory GiveModel.fromJson(Map<String, dynamic> json) =>
      _$GiveModelFromJson(json);

  Map<String, dynamic> toJson() => _$GiveModelToJson(this);
}
