import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

Future<bool> showCancelItemDialog(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 32.0,
            ),
            Text('Точно хотите закрыть?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.8),
                )),
            SizedBox(
              height: 16.0,
            ),
            Text('Вы очень близки к тому,\nчтобы отдать эту вещь.'),
            SizedBox(
              height: 8.0,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FlatButton(
                  child: Text('Закрыть'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                SizedBox(width: 8),
                FlatButton(
                  child: Text('Остаться'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            SizedBox(
              height: 32.0,
            ),
          ],
        ),
      );
    },
  );
}
