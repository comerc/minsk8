import 'package:json_annotation/json_annotation.dart';

enum ClaimValue {
  forbidden,
  repeat,
  duplicate,
  @JsonValue('invalid_kind')
  invalidKind,
  other,
}
