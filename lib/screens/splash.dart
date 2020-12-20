import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class SplashScreen extends StatelessWidget {
  Route<T> getRoute<T>() {
    return buildRoute<T>(
      '/splash',
      builder: (_) => this,
      fullscreenDialog: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _Logo(),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/bloc_logo_small.png',
      key: Key('$runtimeType'),
      width: 150,
    );
  }
}
