import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'proclamation.g.dart';

@JsonSerializable()
class ProclamationModel {
  final String id;
  @JsonKey(nullable: true)
  final ItemModel item;
  final String text;

  ProclamationModel({
    this.id,
    this.item,
    this.text,
  });

  factory ProclamationModel.fromJson(Map<String, dynamic> json) =>
      _$ProclamationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProclamationModelToJson(this);
}
