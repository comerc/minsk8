import 'package:json_annotation/json_annotation.dart';
// import 'package:minsk8/import.dart';

part 'notification.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  final String text;
  @JsonKey(nullable: true)
  final String itemId;
  final DateTime createdAt;

  NotificationModel({
    this.id,
    this.text,
    this.itemId,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
