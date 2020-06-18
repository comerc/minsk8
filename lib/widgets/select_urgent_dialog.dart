import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

Future<UrgentStatus> selectUrgentDialog(
    BuildContext context, UrgentStatus selected) {
  return showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16, bottom: 16, top: 32),
              child: Text('Как срочно надо отдать?'),
            ),
            ...List.generate(
              urgents.length,
              (i) => InkWell(
                child: ListTile(
                  title: Text(urgents[i].name),
                  subtitle: Text(urgents[i].description),
                  selected: selected == urgents[i].value,
                  trailing: Icon((selected == urgents[i].value
                      ? Icons.check_box
                      : Icons.check_box_outline_blank)),
                  dense: true,
                ),
                onTap: () {
                  Navigator.of(context).pop(urgents[i].value);
                },
              ),
            ),
            SizedBox(height: 32)
          ],
        ),
      );
    },
  );
}
