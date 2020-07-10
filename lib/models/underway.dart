import 'package:minsk8/import.dart';

enum UnderwayValue { wish, want, past, give }

class UnderwayModel implements EnumModel {
  UnderwayModel(this.value, this.name);
  final UnderwayValue value;
  final String name;

  get enumValue => value;
  get enumName => name;
}
