import 'package:minsk8/import.dart';

class UrgentModel implements EnumModel {
  UrgentModel(UrgentValue value, String name, this.text)
      : _value = value,
        _name = name;

  final UrgentValue _value;
  final String _name;
  final String text;

  @override
  UrgentValue get value => _value;
  @override
  String get name => _name;
}

enum UrgentValue { very_urgent, urgent, not_urgent, none }

final kUrgents = <UrgentModel>[
  UrgentModel(UrgentValue.very_urgent, 'Очень срочно', 'Сегодня-завтра'),
  UrgentModel(UrgentValue.urgent, 'Срочно', 'Ближайшие дни'),
  UrgentModel(UrgentValue.not_urgent, 'Не срочно', 'Ближайшую неделю'),
  UrgentModel(UrgentValue.none, 'Совсем не срочно', 'Выгодно для ценных лотов'),
];
