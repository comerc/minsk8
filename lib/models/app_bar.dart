import 'package:flutter/foundation.dart';

class AppBarModel extends ChangeNotifier {
  bool _isElevation = false;
  bool get isElevation => _isElevation;
  set isElevation(bool value) {
    if (_isElevation == value) return;
    _isElevation = value;
    notifyListeners();
  }
}
