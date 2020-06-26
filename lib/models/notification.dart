import 'package:json_annotation/json_annotation.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:minsk8/import.dart';

part 'notification.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  @JsonKey(nullable: true)
  final ItemModel item;
  @JsonKey(fromJson: _questionFromString, toJson: _questionToString)
  final QuestionValue question;
  @JsonKey(nullable: true)
  final String text;
  final DateTime createdAt;

  NotificationModel({
    this.id,
    this.item,
    this.question,
    this.text,
    this.createdAt,
  });

  static _questionFromString(String value) =>
      EnumToString.fromString(QuestionValue.values, value);

  static _questionToString(QuestionValue question) =>
      EnumToString.parse(question);

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
