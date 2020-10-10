import 'package:minsk8/import.dart';

// TODO: 10 Кармы за 5 новых в сутки

class InviteScreen extends StatelessWidget {
  PageRoute<T> route<T>() {
    return buildRoute<T>(
      '/invite',
      builder: (_) => this,
      fullscreenDialog: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      alignment: Alignment.topCenter,
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 16),
                Logo(),
                SizedBox(height: 48),
                Text(
                  'Приглашайте друзей\nи получайте Карму',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Получите бонус +1 Кармы\nза каждого нового участника,\nкоторый пришёл по Вашим ссылкам',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          Container(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                FlatButton(
                  child: Text('Пригласить друзей'),
                  onPressed: () {
                    // TODO: [MVP] go to share link
                  },
                  color: Colors.green,
                  textColor: Colors.white,
                ),
                OutlineButton(
                  child: Text('Пригласить позже'),
                  onLongPress: () {}, // чтобы сократить время для splashColor
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  textColor: Colors.black.withOpacity(0.8),
                ),
              ],
            ),
          ),
          SizedBox(height: 48),
        ],
      ),
    );
    return Scaffold(
      body: ScrollBody(child: child),
    );
  }
}
