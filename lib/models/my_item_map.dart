import 'package:flutter/foundation.dart';
import 'package:minsk8/import.dart';

// TODO: переделать управление состоянием UI на GlobalKey

class MyItemMapModel extends ChangeNotifier {
  String _address;
  String get address => _address;
  bool _visible;
  bool get visible => _visible;

  void hide() {
    _visible = false;
    notifyListeners();
  }

  void show(String address) {
    _address = address;
    _visible = true;
    notifyListeners();
  }

  void init() {
    _address = appState['MyItemMap.address'] ?? '(none)';
    _visible = true;
  }
}
