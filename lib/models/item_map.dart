import 'package:flutter/foundation.dart';
// import 'package:minsk8/import.dart';

class ItemMapModel extends ChangeNotifier {
  String _value = '(не определён)';
  String get value => _value;
  bool _visible = true;
  bool get visible => _visible;

  hide() {
    _visible = false;
    notifyListeners();
  }

  show(String value) {
    _value = value;
    _visible = true;
    notifyListeners();
  }
}
