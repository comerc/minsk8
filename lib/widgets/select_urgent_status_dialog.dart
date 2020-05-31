import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

Future<int> selectUrgentStatusDialog(BuildContext context, int selectedIndex) {
  return showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.only(left: 16.0, bottom: 16.0, top: 32.0),
              child: Text('Как срочно надо отдать?'),
            ),
            ...List.generate(
              urgents.length,
              (i) => InkWell(
                child: ListTile(
                  title: Text(urgents[i].name),
                  subtitle: Text(urgents[i].description),
                  selected: selectedIndex == i,
                  trailing: Icon((selectedIndex == i
                      ? Icons.check_box
                      : Icons.check_box_outline_blank)),
                  dense: true,
                ),
                onTap: () {
                  Navigator.of(context).pop(i);
                },
              ),
            ),
            SizedBox(
              height: 32.0,
            )
          ],
        ),
      );
    },
  );
}
