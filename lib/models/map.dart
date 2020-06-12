import 'package:flutter/foundation.dart';
// import 'package:minsk8/import.dart';

class MapModel extends ChangeNotifier {
  String _value;
  String get value => _value;
  set value(String v) {
    _value = v;
    notifyListeners();
  }
}
