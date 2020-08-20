import 'package:minsk8/import.dart';

class UrgentModel implements EnumModel {
  UrgentModel(UrgentStatus value, String name, this.text)
      : _value = value,
        _name = name;

  final UrgentStatus _value;
  final String _name;
  final String text;

  @override
  UrgentStatus get value => _value;
  @override
  String get name => _name;
}

enum UrgentStatus { very_urgent, urgent, not_urgent, none }

final kUrgents = <UrgentModel>[
  UrgentModel(UrgentStatus.very_urgent, 'Очень срочно', 'Сегодня-завтра'),
  UrgentModel(UrgentStatus.urgent, 'Срочно', 'Ближайшие дни'),
  UrgentModel(UrgentStatus.not_urgent, 'Не срочно', 'Ближайшую неделю'),
  UrgentModel(
      UrgentStatus.none, 'Совсем не срочно', 'Выгодно для ценных лотов'),
];
