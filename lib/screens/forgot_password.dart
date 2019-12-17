import "package:flutter/material.dart";
import '../widgets/main_drawer.dart';

class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      drawer: MainDrawer('/forgot_password'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}
