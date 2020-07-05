import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class EditItemScreen extends StatelessWidget {
  EditItemScreen(this.arguments);

  final EditItemRouteArguments arguments;

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
  EditItemRouteArguments(this.id);

  final int id;
}
