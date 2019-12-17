import "package:flutter/material.dart";
import '../widgets/main_drawer.dart';

class PayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pay'),
      ),
      drawer: MainDrawer('/pay'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}
