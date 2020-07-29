import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

class BalanceDialog extends StatefulWidget {
  @override
  _BalanceDialogState createState() {
    return _BalanceDialogState();
  }
}

class _BalanceDialogState extends State<BalanceDialog> {
// class BalanceDialog extends StatelessWidget {
  @override
  void initState() {
    super.initState();
    App.analytics.setCurrentScreen(screenName: '/balance_dalog');
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileModel>(context, listen: false);
    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: <Widget>[
        SizedBox(
          height: 16,
        ),
        Container(
          alignment: Alignment.topCenter,
          child: Avatar(
            profile.member.avatarUrl,
            radius: kBigAvatarRadius,
          ),
        ),
        SizedBox(
          height: 16,
        ),
        Text(
          'У Вас ${getPluralKarma(profile.balance)}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        SizedBox(
          height: 8,
        ),
        OutlineButton(
          child: Text('Движение Кармы'),
          onLongPress: () {}, // чтобы сократить время для splashColor
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          textColor: Colors.green,
        ),
        FlatButton(
          child: Text('Повысить Карму'),
          onLongPress: () {}, // чтобы сократить время для splashColor
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/how_to_pay');
          },
          color: Colors.green,
          textColor: Colors.white,
        ),
      ],
    );
  }
}
