import 'package:json_annotation/json_annotation.dart';

enum ClaimValue {
  forbidden,
  repeat,
  duplicate,
  @JsonValue('invalid_kind')
  invalidKind,
  other,
}

String getClaimName(ClaimValue value) {
  final map = {
    ClaimValue.forbidden: 'Запрещённый лот',
    ClaimValue.repeat: 'Размещён повторно',
    ClaimValue.duplicate: 'Дубликат',
    ClaimValue.invalidKind: 'Неверная категория',
    ClaimValue.other: 'Другое',
  };
  assert(ClaimValue.values.length == map.length);
  return map[value];
}
