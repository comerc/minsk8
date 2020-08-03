import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: Text('xxx'),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      drawer: MainDrawer('/sign_up'),
      body: buildScrollBody(child),
    );
  }
}
