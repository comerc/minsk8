import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'wish.g.dart';

@JsonSerializable()
class WishModel {
  WishModel({
    this.updatedAt,
    this.unit,
    this.unitId,
  });

  final DateTime updatedAt;
  @JsonKey(nullable: true) // надо для MyWishesModel
  UnitModel unit;
  @JsonKey(nullable: true) // надо для getWishUnits
  final String unitId;

  factory WishModel.fromJson(Map<String, dynamic> json) =>
      _$WishModelFromJson(json);

  Map<String, dynamic> toJson() => _$WishModelToJson(this);
}
