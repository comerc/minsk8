import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class EditUnitScreen extends StatelessWidget {
  EditUnitScreen(this.arguments);

  final EditUnitRouteArguments arguments;

  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: Text('xxx'),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Unit'),
      ),
      drawer: MainDrawer('/edit_unit'),
      body: ScrollBody(child: child),
    );
  }
}

class EditUnitRouteArguments {
  EditUnitRouteArguments(this.id);

  final int id;
}
