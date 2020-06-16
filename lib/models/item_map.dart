import 'package:flutter/foundation.dart';
import 'package:minsk8/import.dart';

// TODO: переделать управление состоянием UI на GlobalKey

class ItemMapModel extends ChangeNotifier {
  String _value = appState['location'] ?? '(none)';
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
