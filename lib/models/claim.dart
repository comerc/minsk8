import 'package:minsk8/import.dart';

class ClaimModel implements EnumModel {
  ClaimModel(this.value, this.name);

  final ClaimValue value;
  final String name;

  @override
  ClaimValue get enumValue => value;
  @override
  String get enumName => name;
}

enum ClaimValue { forbidden, repeat, duplicate, invalid_kind, other }

final claims = [
  ClaimModel(ClaimValue.forbidden, 'Запрещённый лот'),
  ClaimModel(ClaimValue.repeat, 'Размещён повторно'),
  ClaimModel(ClaimValue.duplicate, 'Дубликат'),
  ClaimModel(ClaimValue.invalid_kind, 'Неверная категория'),
  ClaimModel(ClaimValue.other, 'Другое'),
];
