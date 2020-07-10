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
              (index) => InkWell(
                child: ListTile(
                  title: Text(urgents[index].name),
                  subtitle: Text(urgents[index].text),
                  selected: selected == urgents[index].value,
                  trailing: Icon((selected == urgents[index].value
                      ? Icons.check_box
                      : Icons.check_box_outline_blank)),
                  dense: true,
                ),
                onTap: () {
                  Navigator.of(context).pop(urgents[index].value);
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
