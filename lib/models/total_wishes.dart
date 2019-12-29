import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'total_wishes.g.dart';

@JsonSerializable()
class TotalWishesModel {
  final int value;

  TotalWishesModel(this.value);

  factory TotalWishesModel.fromJson(Map<String, dynamic> json) =>
      _$TotalWishesModelFromJson(json);

  Map<String, dynamic> toJson() => _$TotalWishesModelToJson(this);
}
