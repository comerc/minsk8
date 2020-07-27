import 'package:json_annotation/json_annotation.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:minsk8/import.dart';

part 'suggestion.g.dart';

@JsonSerializable()
class SuggestionModel {
  SuggestionModel({
    this.id,
    this.unit,
    this.question,
  });

  final String id;
  final UnitModel unit;
  // @JsonKey(fromJson: _questionFromString, toJson: _questionToString)
  final QuestionValue question;

  // static QuestionValue _questionFromString(String value) =>
  //     EnumToString.fromString(QuestionValue.values, value);

  // static String _questionToString(QuestionValue question) =>
  //     EnumToString.parse(question);

  factory SuggestionModel.fromJson(Map<String, dynamic> json) =>
      _$SuggestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestionModelToJson(this);
}
