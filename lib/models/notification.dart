import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'notification.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  @JsonKey(nullable: true)
  final ItemModel item;
  final String text;
  final DateTime createdAt;

  NotificationModel({
    this.id,
    this.item,
    this.text,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
