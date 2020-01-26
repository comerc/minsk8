import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class MyItemMapScreen extends StatefulWidget {
  MyItemMapScreen(this.arguments);

  final MyItemMapRouteArguments arguments;

  @override
  _MyItemMapScreenState createState() {
    return _MyItemMapScreenState();
  }
}

class _MyItemMapScreenState extends State<MyItemMapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Item Map'),
      ),
      body: MapWidget(),
    );
  }
}

class MyItemMapRouteArguments {
  MyItemMapRouteArguments(this.item);

  final ItemModel item;
}
