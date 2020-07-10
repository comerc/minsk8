import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'wish.g.dart';

// TODO: удалить profile.wishes.item

@JsonSerializable()
class WishModel {
  final DateTime createdAt;
  @JsonKey(nullable: true) // надо для items.wishes
  ItemModel item;
  @JsonKey(nullable: true) // надо для items.wishes
  final String itemId;

  WishModel({
    this.createdAt,
    this.item,
    this.itemId,
  });

  factory WishModel.fromJson(Map<String, dynamic> json) =>
      _$WishModelFromJson(json);

  Map<String, dynamic> toJson() => _$WishModelToJson(this);
}
