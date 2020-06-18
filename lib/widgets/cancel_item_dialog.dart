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
              height: 32,
            ),
            Text('Точно хотите закрыть?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.8),
                )),
            SizedBox(
              height: 16,
            ),
            Text('Вы очень близки к тому,\nчтобы отдать эту вещь.'),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlineButton(
                  child: Text('Закрыть'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                SizedBox(
                  width: 16,
                ),
                FlatButton(
                  child: Text('Остаться'),
                  onPressed: () => Navigator.of(context).pop(false),
                  color: Colors.red,
                  textColor: Colors.white,
                ),
              ],
            ),
            SizedBox(
              height: 32,
            ),
          ],
        ),
      );
    },
  );
}
