import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: MainDrawer('/'),
      body: Center(
        child: Text('Hello world!'),
      ),
    );
  }
}
