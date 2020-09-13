import 'package:flutter/foundation.dart';
import 'package:package_info/package_info.dart';

class VersionModel extends ChangeNotifier {
  String _value = '';
  String get value => _value;

  void init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _value = '${packageInfo.version}+${packageInfo.buildNumber}';
    notifyListeners();
  }
}
