import 'package:flutter/material.dart';
// import 'package:minsk8/import.dart';

class ConfirmDialog extends StatelessWidget {
  ConfirmDialog({this.title, this.content, this.cancel, this.ok});

  final String title;
  final String content;
  final String cancel;
  final String ok;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              // fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            content,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              OutlineButton(
                child: Text(cancel ?? 'Отмена'),
                onLongPress: () {}, // чтобы сократить время для splashColor
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(
                width: 16,
              ),
              FlatButton(
                child: Text(ok),
                onLongPress: () {}, // чтобы сократить время для splashColor
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                color: Colors.green,
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
