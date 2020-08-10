import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

// TODO: flutter_secure_storage для хранения токена авторизации?
// TODO: [MVP] реализовать авторизацию через: FB, Google, Apple Id, VK, Telegram

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: Text('Login'),
    );
    return Scaffold(
      appBar: ExtendedAppBar(
        withModel: true,
      ),
      drawer: MainDrawer('/login'),
      body: SafeArea(
        child: ScrollBody(child: child),
      ),
    );
  }
}
