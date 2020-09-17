import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

// class BlockDialog extends StatefulWidget {
//   @override
//   BlockDialogState createState() {
//     return BlockDialogState();
//   }
// }

// class BlockDialogState extends State<BlockDialog> {
//   @override
//   void initState() {
//     super.initState();
//     analytics.setCurrentScreen(screenName: '/block_dialog');
//   }

class BlockDialog extends StatelessWidget {
  BlockDialog(this.isBlocked);

  final bool isBlocked;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: <Widget>[
        Container(
          constraints: BoxConstraints(
            maxWidth: 200,
          ),
          child: Text(
            'Если победитель повёл себя некорректно\u00A0— заблокируйте его, чтобы он больше не\u00A0мог делать ставки на\u00A0Ваши\u00A0лоты. В\u00A0случае крайней необходимости\u00A0— напишите в\u00A0службу\u00A0поддержки.',
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 8,
        ),
        FlatButton(
          child: Text(isBlocked
              ? 'Разблокировать участника'
              : 'Заблокировать участника'),
          onLongPress: () {}, // чтобы сократить время для splashColor
          onPressed: () {
            Navigator.of(context).pop(isBlocked ? 'unblock' : 'block');
          },
          color: Colors.green,
          textColor: Colors.white,
        ),
        OutlineButton(
          child: Text('Написать в поддержку'),
          onLongPress: () {}, // чтобы сократить время для splashColor
          onPressed: () {
            Navigator.of(context).pop('feedback');
          },
          textColor: Colors.green,
        ),
      ],
    );
  }
}
