import "package:flutter/material.dart";
import '../widgets/main_drawer.dart';

class KindsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kinds'),
      ),
      drawer: MainDrawer('/kinds'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}
