class ClaimModel {
  final ClaimValue value;
  final String name;

  ClaimModel(this.value, this.name);
}

enum ClaimValue { forbidden, repeat, duplicate, invalid_kind, other }

final claims = [
  ClaimModel(ClaimValue.forbidden, 'Запрещённый лот'),
  ClaimModel(ClaimValue.repeat, 'Размещён повторно'),
  ClaimModel(ClaimValue.duplicate, 'Дубликат'),
  ClaimModel(ClaimValue.invalid_kind, 'Неверная категория'),
  ClaimModel(ClaimValue.other, 'Другое'),
];
