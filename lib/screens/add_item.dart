import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

// TODO: item.text.trim()

class AddItemScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item'),
      ),
      drawer: MainDrawer('/add_item'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}
