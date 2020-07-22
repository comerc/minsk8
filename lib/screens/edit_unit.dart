import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class EditUnitScreen extends StatelessWidget {
  EditUnitScreen(this.arguments);

  final EditUnitRouteArguments arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Unit'),
      ),
      drawer: MainDrawer('/edit_unit'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}

class EditUnitRouteArguments {
  EditUnitRouteArguments(this.id);

  final int id;
}
