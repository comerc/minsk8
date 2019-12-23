import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

Widget buildAddButton(BuildContext context) {
  return FloatingActionButton(
    onPressed: () {
      Navigator.pushNamed(
        context,
        '/add_item',
      );
    },
    tooltip: 'Add Item',
    child: Icon(Icons.add),
    elevation: 2.0,
  );
}
