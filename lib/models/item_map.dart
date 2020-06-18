import 'package:flutter/foundation.dart';
import 'package:minsk8/import.dart';

// TODO: переделать управление состоянием UI на GlobalKey

class ItemMapModel extends ChangeNotifier {
  String _location;
  String get location => _location;
  bool _visible;
  bool get visible => _visible;

  hide() {
    _visible = false;
    notifyListeners();
  }

  show(String location) {
    _location = location;
    _visible = true;
    notifyListeners();
  }

  init() {
    _location = appState['location'] ?? '(none)';
    _visible = true;
  }
}
