import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

class HowToPayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить Золотых'),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    FontAwesomeIcons.gift,
                    color: Colors.deepOrangeAccent,
                    size: kBigButtonIconSize,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'У Вас ${getPluralGold(profile.balance)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        'увеличьте их одним из способов',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  _Menu(),
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

class _Menu extends StatelessWidget {
  final _menu = {
    '/add_unit': [
      'ОТДАЙТЕ ХОРОШИЕ ВЕЩИ',
      'получите за них Золотые от участников'
    ],
    '/invite': ['ПРИГЛАСИТЕ ДРУЗЕЙ', 'получите +1 Золотой за каждого новичка'],
    '/pay': [
      'ПОЛУЧИТЕ БЫСТРО',
      'до +${getPluralGold(kMaxPay)} за поддержку проекта'
    ],
  }.entries.toList();

  @override
  Widget build(BuildContext context) {
    return GlowNotificationWidget(
      ListView.separated(
        shrinkWrap: true,
        itemCount: _menu.length,
        itemBuilder: (BuildContext context, int index) {
          final entry = _menu[index];
          return Material(
            child: InkWell(
              child: ListTile(
                title: index == _menu.length - 1
                    ? Text(
                        entry.value[0],
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      )
                    : Text(entry.value[0]),
                subtitle: Text(entry.value[1]),
                trailing: Icon(
                  Icons.navigate_next,
                  color: Colors.black.withOpacity(0.8),
                  size: kButtonIconSize,
                ),
              ),
              onTap: () {
                if (entry.key == '/add_unit') {
                  Navigator.pushNamed(
                    context,
                    '/kinds',
                  ).then((kind) {
                    if (kind == null) return;
                    Navigator.pushNamed(
                      context,
                      '/add_unit',
                      arguments: AddUnitRouteArguments(
                        kind: kind,
                        tabIndex: AddUnitRouteArgumentsTabIndex(),
                      ),
                    );
                  });
                } else {
                  Navigator.of(context).pushNamed(entry.key);
                }
              },
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            indent: 16,
            endIndent: 16,
            height: 1,
          );
        },
      ),
    );
  }
}
