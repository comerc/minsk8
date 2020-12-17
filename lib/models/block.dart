import 'package:json_annotation/json_annotation.dart';
// import 'package:minsk8/import.dart';

part 'block.g.dart';

@JsonSerializable()
class BlockModel {
  BlockModel({
    this.memberId,
    this.updatedAt,
  });

  final String memberId;
  final DateTime updatedAt;

  static BlockModel fromJson(Map<String, dynamic> json) =>
      _$BlockModelFromJson(json);

  Map<String, dynamic> toJson() => _$BlockModelToJson(this);
}
