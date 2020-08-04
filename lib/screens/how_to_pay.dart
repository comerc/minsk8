import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minsk8/import.dart';

class HowToPayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final child = Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _BigLogo(),
                _Title(),
                _Menu(),
              ],
            ),
          ),
          FlatButton(
            child: Text(
              'КАК ЭТО РАБОТАЕТ?',
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
    );
    return Scaffold(
      appBar: ExtendedAppBar(
        backgroundColor: Colors.transparent,
      ),
      body: buildScrollBody(child),
    );
  }
}

class _Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Повысить Карму',
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
          'чтобы забирать нужные вещи',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _BigLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final height = 150.0;
    final width = 200.0;
    return Container(
      height: height,
      width: width,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: height / 2 - kLogoSize / 2 + 10,
            left: width / 2 - kLogoSize / 2,
            child: Logo(),
          ),
          Positioned(
            bottom: 0,
            left: 20,
            child: Transform.rotate(
              angle: -.4,
              child: Icon(
                FontAwesomeIcons.cat,
                color: Colors.deepOrangeAccent,
                size: kLogoSize / kGoldenRatio,
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 0,
            child: Transform.rotate(
              angle: -.4,
              child: Icon(
                FontAwesomeIcons.bicycle,
                color: Colors.deepOrangeAccent,
                size: kLogoSize / kGoldenRatio,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 100,
            child: Transform.rotate(
              angle: .4,
              child: Icon(
                FontAwesomeIcons.chair,
                color: Colors.deepOrangeAccent,
                size: kLogoSize / kGoldenRatio,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 0,
            child: Transform.rotate(
              angle: -.4,
              child: Icon(
                FontAwesomeIcons.mobileAlt,
                color: Colors.deepOrangeAccent,
                size: kLogoSize / kGoldenRatio,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 20,
            child: Transform.rotate(
              angle: -.4,
              child: Icon(
                FontAwesomeIcons.wineBottle,
                color: Colors.deepOrangeAccent,
                size: kLogoSize / kGoldenRatio,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  final _menu = {
    '/add_unit': ['ОТДАЙТЕ ЛИШНИЕ ВЕЩИ', 'Получите за них Карму от забирающих'],
    '/invite': ['ПРИГЛАСИТЕ ДРУЗЕЙ', 'Получите Карму за новых участников'],
    '/payment': ['ПОЛУЧИТЕ КАРМУ БЫСТРО', 'Поддержите развитие проекта'],
  }.entries.toList();

  @override
  Widget build(BuildContext context) {
    return ListBox(
      itemCount: _menu.length,
      itemBuilder: (BuildContext context, int index) {
        final entry = _menu[index];
        return Material(
          color: index == _menu.length - 1 ? Colors.green : Colors.white,
          child: InkWell(
            child: ListTile(
              dense: true,
              title: index == _menu.length - 1
                  ? Text(
                      entry.value[0],
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )
                  : Text(entry.value[0]),
              subtitle: index == _menu.length - 1
                  ? Text(
                      entry.value[1],
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )
                  : Text(entry.value[1]),
              trailing: Icon(
                Icons.navigate_next,
                color: index == _menu.length - 1
                    ? Colors.white
                    : Colors.black.withOpacity(0.3),
                size: kButtonIconSize,
              ),
            ),
            onLongPress: () {}, // чтобы сократить время для splashColor
            onTap: () {
              if (entry.key == '/add_unit') {
                Navigator.pushNamed(
                  context,
                  '/kinds',
                ).then((kind) {
                  if (kind == null) return null;
                  return Navigator.pushNamed(
                    context,
                    '/add_unit',
                    arguments: AddUnitRouteArguments(
                      kind: kind,
                      tabIndex: AddUnitRouteArgumentsTabIndex(),
                    ),
                  );
                }).whenComplete(() {
                  Navigator.of(context).pop();
                });
                return;
              }
              Navigator.of(context).pushReplacementNamed(entry.key);
            },
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 8);
      },
    );
  }
}
