import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

typedef AddItemRouteArgumentsTabIndex GetTabIndexCallback();

Widget buildAddButton(BuildContext context, {GetTabIndexCallback getTabIndex}) {
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
            tabIndex: getTabIndex(),
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
