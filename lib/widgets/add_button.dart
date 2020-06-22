import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

Widget buildAddButton(BuildContext context,
    {List<ItemsRepository> sourceListPool}) {
  return FloatingActionButton(
    backgroundColor: Colors.white,
    foregroundColor: Colors.pinkAccent,
    onPressed: () {
      Navigator.pushNamed(
        context,
        '/kinds',
      ).then((kind) {
        if (kind == null) return;
        Navigator.pushNamed(
          context,
          '/add_item',
          arguments: AddItemRouteArguments(
            kind: kind,
            sourceListPool: sourceListPool,
          ),
        );
      });
    },
    tooltip: 'Add Item',
    child: Icon(
      Icons.add,
      size: kBigButtonIconSize * 1.2,
    ),
    elevation: 2,
  );
}
