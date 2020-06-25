import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class ClaimDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Укажите причину жалобы'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          claims.length,
          (i) => InkWell(
            child: ListTile(
              title: Text(claims[i].name),
            ),
            onTap: () {
              Navigator.of(context).pop(claims[i].value);
            },
          ),
        ),
      ),
      actions: [
        FlatButton(
          child: Text('Отмена'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
