import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'wish.g.dart';

@JsonSerializable()
class WishModel {
  final DateTime createdAt;
  @JsonKey(nullable: true) // надо для items.wishes
  final ItemModel item;

  WishModel(
    this.createdAt,
    this.item,
  );

  factory WishModel.fromJson(Map<String, dynamic> json) =>
      _$WishModelFromJson(json);

  Map<String, dynamic> toJson() => _$WishModelToJson(this);
}
