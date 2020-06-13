import 'package:flutter/foundation.dart';
// import 'package:minsk8/import.dart';

class ItemMapModel extends ChangeNotifier {
  String _value = "reverse";
  String get value => _value;
  set value(String v) {
    _value = v;
    notifyListeners();
  }
  // bool forward = false;
  // bool get forward => _value;
  // set value(String v) {
  //   _value = v;
  //   notifyListeners();
  // }
}
