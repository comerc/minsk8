import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'my_item.g.dart';

@JsonSerializable()
class MyItemModel {
  final ItemModel item;
  final int likes;

  MyItemModel(this.item, this.likes);

  factory MyItemModel.fromJson(Map<String, dynamic> json) =>
      _$MyItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$MyItemModelToJson(this);
}
