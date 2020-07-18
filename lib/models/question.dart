import 'package:minsk8/import.dart';

class QuestionModel implements EnumModel {
  QuestionModel(this.value, this.name);

  final QuestionValue value;
  final String name;

  @override
  QuestionValue get enumValue => value;
  @override
  String get enumName => name;
}

enum QuestionValue { condition, model, size, time, original }

// TODO: для категории "Услуги" нужны другие вопросы

final questions = [
  QuestionModel(QuestionValue.condition, 'Состояние и работоспособность'),
  QuestionModel(QuestionValue.model, 'Модель'),
  QuestionModel(QuestionValue.size, 'Размер'),
  QuestionModel(QuestionValue.time, 'В какое время можно забрать?'),
  QuestionModel(QuestionValue.original, 'Это оригинал или реплика?'),
];

final questionTexts = {
  QuestionValue.condition: 'Добавьте описание состояния и работоспособности',
  QuestionValue.model: 'Добавьте описание модели',
  QuestionValue.size: 'Добавьте описание размера',
  QuestionValue.time: 'Уточните в описании время, когда можно забрать лот',
  QuestionValue.original: 'Уточните в описании - это оригинал или реплика?',
};
