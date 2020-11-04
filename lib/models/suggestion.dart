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

  Map<String, dynamic> toJson() => _$SuggestionModelToJson(this);
}

// TODO: для категории "Услуги" нужны другие вопросы

enum QuestionValue {
  condition,
  model,
  size,
  time,
  original,
}

String getQuestionName(QuestionValue value) {
  final map = {
    QuestionValue.condition: 'Состояние и работоспособность',
    QuestionValue.model: 'Модель',
    QuestionValue.size: 'Размер',
    QuestionValue.time: 'В какое время можно забрать?',
    QuestionValue.original: 'Это оригинал или реплика?',
  };
  assert(QuestionValue.values.length == map.length);
  return map[value];
}

String getQuestionText(QuestionValue value) {
  final map = {
    QuestionValue.condition: 'Добавьте описание состояния и работоспособности',
    QuestionValue.model: 'Добавьте описание модели',
    QuestionValue.size: 'Добавьте описание размера',
    QuestionValue.time: 'Уточните в описании время, когда можно забрать лот',
    QuestionValue.original: 'Уточните в описании - это оригинал или реплика?',
  };
  assert(QuestionValue.values.length == map.length);
  return map[value];
}
