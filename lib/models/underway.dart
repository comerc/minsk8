import 'package:minsk8/import.dart';

enum UnderwayValue {
  wish,
  want,
  // take,
  // past,
  give
}

class UnderwayModel implements EnumModel {
  UnderwayModel(this.value, this.name);
  final UnderwayValue value;
  final String name;

  @override
  UnderwayValue get enumValue => value;
  @override
  String get enumName => name;
}
