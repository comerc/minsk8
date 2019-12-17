import "package:flutter/material.dart";
import '../widgets/main_drawer.dart';

class MyItemsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Items'),
      ),
      drawer: MainDrawer('/my_items'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}
