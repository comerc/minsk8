import 'package:minsk8/import.dart';

Widget buildModalBottomSheet(BuildContext context, {String description}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
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
      Text(
        description,
        textAlign: TextAlign.center,
      ),
      SizedBox(
        height: 16,
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          OutlineButton(
            onLongPress: () {}, // чтобы сократить время для splashColor
            onPressed: () {
              navigator.pop(true);
            },
            textColor: Colors.black.withOpacity(0.8),
            child: Text('Закрыть'),
          ),
          SizedBox(
            width: 16,
          ),
          FlatButton(
            onLongPress: () {}, // чтобы сократить время для splashColor
            onPressed: () {
              navigator.pop(false);
            },
            color: Colors.green,
            textColor: Colors.white,
            child: Text('Остаться'),
          ),
        ],
      ),
      SizedBox(
        height: 32,
      ),
    ],
  );
}
