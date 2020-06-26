import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'notification.g.dart';

@JsonSerializable()
class NotificationModel {
  final DateTime createdAt;
  @JsonKey(nullable: true)
  final ProclamationModel proclamation;
  @JsonKey(nullable: true)
  final SuggestionModel suggestion;

  NotificationModel({
    this.createdAt,
    this.proclamation,
    this.suggestion,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
