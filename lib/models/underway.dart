import 'package:minsk8/import.dart';

class UnderwayModel implements EnumModel {
  UnderwayModel(UnderwayValue value, String name)
      : _value = value,
        _name = name;

  final UnderwayValue _value;
  final String _name;

  @override
  UnderwayValue get value => _value;
  @override
  String get name => _name;
}

enum UnderwayValue {
  wish,
  want,
  // take,
  // past,
  give
}
