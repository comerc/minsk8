import 'package:minsk8/import.dart';

class InteractionModel implements EnumModel {
  InteractionModel(InteractionValue value, String name)
      : _value = value,
        _name = name;

  final InteractionValue _value;
  final String _name;

  @override
  InteractionValue get value => _value;
  @override
  String get name => _name;
}

enum InteractionValue { chat, notice }
