import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'block.g.dart';

@JsonSerializable()
class BlockModel {
  BlockModel({
    this.createdAt,
    this.memberId,
  });

  final DateTime createdAt;
  final String memberId;

  factory BlockModel.fromJson(Map<String, dynamic> json) =>
      _$BlockModelFromJson(json);

  Map<String, dynamic> toJson() => _$BlockModelToJson(this);
}
