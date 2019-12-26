import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class EditItemScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Item'),
      ),
      drawer: MainDrawer('/edit_item'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}

class EditItemRouteArguments {
  final int id;

  EditItemRouteArguments(this.id);
}
