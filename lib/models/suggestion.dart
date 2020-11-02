import 'package:json_annotation/json_annotation.dart';
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
  final QuestionValue question;

  factory SuggestionModel.fromJson(Map<String, dynamic> json) =>
      _$SuggestionModelFromJson(json);
}

// TODO: для категории "Услуги" нужны другие вопросы

enum QuestionValue {
  condition,
  model,
  size,
  time,
  original,
}
