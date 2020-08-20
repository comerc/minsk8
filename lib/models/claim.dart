import 'package:minsk8/import.dart';

class ClaimModel implements EnumModel {
  ClaimModel(ClaimValue value, String name)
      : _value = value,
        _name = name;

  final ClaimValue _value;
  final String _name;

  @override
  ClaimValue get value => _value;
  @override
  String get name => _name;
}

enum ClaimValue { forbidden, repeat, duplicate, invalid_kind, other }

final kClaims = <ClaimModel>[
  ClaimModel(ClaimValue.forbidden, 'Запрещённый лот'),
  ClaimModel(ClaimValue.repeat, 'Размещён повторно'),
  ClaimModel(ClaimValue.duplicate, 'Дубликат'),
  ClaimModel(ClaimValue.invalid_kind, 'Неверная категория'),
  ClaimModel(ClaimValue.other, 'Другое'),
];
