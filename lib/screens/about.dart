import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      drawer: MainDrawer('/about'),
      body: Center(
        child: Text('About'),
      ),
    );
  }
}
