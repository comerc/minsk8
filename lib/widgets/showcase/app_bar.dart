import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minsk8/import.dart';

class ShowcaseAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: заменить на стандартный AppBar
    return Container(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: 16),
          Column(
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
          Spacer(),
          AspectRatio(
            aspectRatio: 1,
            child: Tooltip(
              message: 'Настройки',
              child: Material(
                color: Colors.white,
                child: InkWell(
                  borderRadius:
                      BorderRadius.all(Radius.circular(kButtonIconSize * 2)),
                  child: Container(
                    child: Icon(
                      FontAwesomeIcons.slidersH,
                      color: Colors.black.withOpacity(0.8),
                      size: kButtonIconSize,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('/showcase_map');
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
