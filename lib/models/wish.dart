import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'wish.g.dart';

@JsonSerializable()
class WishModel {
  WishModel({
    this.createdAt,
    this.item,
    this.itemId,
  });

  final DateTime createdAt;
  @JsonKey(nullable: true) // надо для MyWishesModel
  ItemModel item;
  @JsonKey(nullable: true) // надо для getWishItems
  final String itemId;

  factory WishModel.fromJson(Map<String, dynamic> json) =>
      _$WishModelFromJson(json);

  Map<String, dynamic> toJson() => _$WishModelToJson(this);
}
