class UrgentModel {
  final UrgentId value;
  final String name;

  UrgentModel(
    this.value,
    this.name,
  );
}

enum UrgentId { very_urgent, urgent, not_urgent, none }

final urgents = [
  UrgentModel(UrgentId.very_urgent, 'Очень срочно'),
  UrgentModel(UrgentId.urgent, 'Срочно'),
  UrgentModel(UrgentId.not_urgent, 'Не срочно'),
  UrgentModel(UrgentId.none, 'Совсем не срочно'),
];
