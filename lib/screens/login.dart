import "package:flutter/material.dart";
import 'package:minsk8/import.dart';

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
