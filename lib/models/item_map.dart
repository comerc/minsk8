import 'package:flutter/foundation.dart';
import 'package:minsk8/import.dart';

// TODO: переделать управление состоянием UI на GlobalKey

class ItemMapModel extends ChangeNotifier {
  String _address;
  String get address => _address;
  bool _visible;
  bool get visible => _visible;

  hide() {
    _visible = false;
    notifyListeners();
  }

  show(String address) {
    _address = address;
    _visible = true;
    notifyListeners();
  }

  init() {
    _address = appState['address'] ?? '(none)';
    _visible = true;
  }
}
