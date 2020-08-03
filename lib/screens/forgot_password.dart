import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: Text('xxx'),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      drawer: MainDrawer('/forgot_password'),
      body: buildScrollBody(child),
    );
  }
}
