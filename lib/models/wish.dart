import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'wish.g.dart';

// TODO: удалить profile.wishes.item, и заменить на itemId

@JsonSerializable()
class WishModel {
  final DateTime createdAt;
  @JsonKey(nullable: true) // надо для items.wishes, profile.wishes
  final ItemModel item;
  // final String itemId; // надо для on_wishes_deleted

  WishModel({
    this.createdAt,
    this.item,
  });

  factory WishModel.fromJson(Map<String, dynamic> json) =>
      _$WishModelFromJson(json);

  Map<String, dynamic> toJson() => _$WishModelToJson(this);
}
