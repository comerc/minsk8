import 'package:flutter/material.dart';
// import 'package:minsk8/import.dart';

Widget buildAddButton(BuildContext context) {
  return FloatingActionButton(
    backgroundColor: Colors.white,
    foregroundColor: Colors.pinkAccent,
    onPressed: () {
      Navigator.pushNamed(
        context,
        '/add_item',
      );
    },
    tooltip: 'Add Item',
    child: Icon(Icons.add, size: 36),
    elevation: 2.0,
  );
}
