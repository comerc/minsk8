import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class UpdateScreen extends StatelessWidget {
  Route<T> getRoute<T>() {
    return buildRoute<T>(
      '/update',
      builder: (_) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('UpdateScreen')),
      backgroundColor: Colors.white,
      body: Center(
        child: Text('Need update'),
      ),
    );
  }
}
