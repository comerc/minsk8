import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: Text('Sign Up'),
    );
    return Scaffold(
      appBar: ExtendedAppBar(
        withModel: true,
      ),
      drawer: MainDrawer('/sign_up'),
      body: SafeArea(
        child: ScrollBody(child: child),
      ),
    );
  }
}
