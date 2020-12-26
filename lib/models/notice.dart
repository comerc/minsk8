import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'notice.g.dart';

@JsonSerializable()
class NoticeModel extends Equatable {
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

  @override
  List<Object> get props => [
        createdAt,
        proclamation,
        suggestion,
      ];

  static NoticeModel fromJson(Map<String, dynamic> json) =>
      _$NoticeModelFromJson(json);

  Map<String, dynamic> toJson() => _$NoticeModelToJson(this);
}
