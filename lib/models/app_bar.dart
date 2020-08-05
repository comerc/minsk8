import 'package:flutter/foundation.dart';

class AppBarModel extends ChangeNotifier {
  bool _isElevation = false;
  bool get isElevation => _isElevation;
  set isElevation(bool value) {
    _isElevation = value;
    notifyListeners();
  }
}
