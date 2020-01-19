class UrgentModel {
  final UrgentStatus value;
  final String name;

  UrgentModel(
    this.value,
    this.name,
  );
}

enum UrgentStatus { very_urgent, urgent, not_urgent, none }

final urgents = [
  UrgentModel(UrgentStatus.very_urgent, 'Очень срочно'),
  UrgentModel(UrgentStatus.urgent, 'Срочно'),
  UrgentModel(UrgentStatus.not_urgent, 'Не срочно'),
  UrgentModel(UrgentStatus.none, 'Совсем не срочно'),
];
