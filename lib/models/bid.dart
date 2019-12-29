import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'bid.g.dart';

@JsonSerializable()
class BidModel {
  final ItemModel item;
  final int value;
  final DateTime updatedAt;

  BidModel(this.item, this.value, this.updatedAt);

  factory BidModel.fromJson(Map<String, dynamic> json) =>
      _$BidModelFromJson(json);

  Map<String, dynamic> toJson() => _$BidModelToJson(this);
}
