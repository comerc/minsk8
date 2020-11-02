import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'notice.g.dart';

@JsonSerializable()
class NoticeModel {
  NoticeModel({
    this.createdAt,
    this.proclamation,
    this.suggestion,
  });

  final DateTime createdAt;
  @JsonKey(nullable: true)
  final ProclamationModel proclamation;
  @JsonKey(nullable: true)
  final SuggestionModel suggestion;

  factory NoticeModel.fromJson(Map<String, dynamic> json) =>
      _$NoticeModelFromJson(json);
}
