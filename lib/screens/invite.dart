import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minsk8/import.dart';

class InviteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Пригласить друзей'),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.gift,
                    color: Colors.deepOrangeAccent,
                    size: 40,
                  ),
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
                ],
              ),
            ),
            Container(
              width: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FlatButton(
                    child: Text('Пригласить друзей'),
                    onPressed: () {
                      // TODO: go to share link
                    },
                    color: Colors.red,
                    textColor: Colors.white,
                  ),
                  OutlineButton(
                    child: Text('Пригласить позже'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    textColor: Colors.black.withOpacity(0.8),
                  ),
                ],
              ),
            ),
            FlatButton(
              child: Text(
                'КАК ЭТО РАБОТАЕТ',
                style: TextStyle(
                  fontSize: kFontSize,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
              onLongPress: () {}, // чтобы сократить время для splashColor
              onPressed: () {
                Navigator.of(context).pushNamed('/how_it_works');
              },
            ),
          ],
        ),
      ),
    );
  }
}
