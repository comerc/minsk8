import "package:flutter/material.dart";
import '../widgets/main_drawer.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      drawer: MainDrawer('/login'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}
