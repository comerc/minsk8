class UrgentModel {
  final UrgentStatus value;
  final String name;
  final String description;

  UrgentModel(
    this.value,
    this.name,
    this.description,
  );
}

enum UrgentStatus { very_urgent, urgent, not_urgent, none }

final urgents = [
  UrgentModel(UrgentStatus.very_urgent, 'Очень срочно', 'Сегодня-завтра'),
  UrgentModel(UrgentStatus.urgent, 'Срочно', 'Ближайшие дни'),
  UrgentModel(UrgentStatus.not_urgent, 'Не срочно', 'Ближайшую неделю'),
  UrgentModel(
      UrgentStatus.none, 'Совсем не срочно', 'Выгодно для ценных лотов'),
];
