import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'underway.g.dart';

@JsonSerializable()
class UnderwayModel {
  final ItemModel item;
  final int bid;

  UnderwayModel(this.item, this.bid);

  factory UnderwayModel.fromJson(Map<String, dynamic> json) =>
      _$UnderwayModelFromJson(json);

  Map<String, dynamic> toJson() => _$UnderwayModelToJson(this);
}
