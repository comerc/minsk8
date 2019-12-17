import "package:flutter/material.dart";
import '../widgets/main_drawer.dart';

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start'),
      ),
      drawer: MainDrawer('/start'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}
