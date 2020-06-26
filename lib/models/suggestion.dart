import 'package:json_annotation/json_annotation.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:minsk8/import.dart';

part 'suggestion.g.dart';

@JsonSerializable()
class SuggestionModel {
  final String id;
  final ItemModel item;
  @JsonKey(fromJson: _questionFromString, toJson: _questionToString)
  final QuestionValue question;

  SuggestionModel({
    this.id,
    this.item,
    this.question,
  });

  static _questionFromString(String value) =>
      EnumToString.fromString(QuestionValue.values, value);

  static _questionToString(QuestionValue question) =>
      EnumToString.parse(question);

  factory SuggestionModel.fromJson(Map<String, dynamic> json) =>
      _$SuggestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestionModelToJson(this);
}
