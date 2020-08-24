import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minsk8/import.dart';

class HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExtendedAppBar(
      isForeground: true,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Text(
              'Без названия',
              style: AppBarTheme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              "${appState['ShowcaseMap.address']} — ${appState['ShowcaseMap.radius']} км",
              style: TextStyle(
                fontSize: kFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        IconButton(
          tooltip: 'Настройки',
          icon: Icon(FontAwesomeIcons.slidersH),
          iconSize: kButtonIconSize,
          onPressed: () {
            Navigator.of(context).pushNamed('/showcase_map');
          },
        ),
      ],
      elevation: 0,
    );
  }
}
