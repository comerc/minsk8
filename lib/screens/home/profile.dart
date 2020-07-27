import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

// TODO: https://github.com/faob-dev/folding_cell
// TODO: https://github.com/Ivaskuu/tinder_cards

// TODO: текстовое поле для описания себя в профиле (усложняет модерацию)
// TODO: при изменении аватарки или баланса - нужно оповещать другие свои устройства

// TODO: AboutDialog - показывает все лицензии, используемые в приложении (см. "Flutter Widget of the Week")

class HomeProfile extends StatefulWidget {
  HomeProfile({this.version, this.hasUpdate});

  final String version;
  final bool hasUpdate;

  @override
  HomeProfileState createState() {
    return HomeProfileState();
  }
}

class HomeProfileState extends State<HomeProfile> {
// class HomeProfile extends StatelessWidget {
//   HomeProfile({this.version, this.hasUpdate});

  final _menu = {
    '/ledger': 'Движение Кармы',
    '/feedback': 'Обратная связь',
    '/faq': 'Вопросы и ответы',
    '/useful_tips': 'Полезные советы',
    '/about': 'О проекте',
  }.entries.toList();

  @override
  void initState() {
    super.initState();
    App.analytics.setCurrentScreen(screenName: '/home/profile');
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileModel>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 16),
        Tooltip(
          message: 'Поменять аватарку',
          child: Avatar(
            profile.member.avatarUrl,
            radius: kBigAvatarRadius,
            elevation: kButtonElevation,
            child: InkWell(
              onTap: () {
                // TODO: загрузка аватарки
                // TODO: распознование лица и обрезание картинки
                // TODO: в телеге можно кликнуть по аватарке, и посмотреть галерею участника (усложняет модерацию)
                showDialog(
                  context: context,
                  child: AlertDialog(
                    content: Text(
                        'Поменять аватарку можно будет в следующей версии.'),
                    actions: [
                      FlatButton(
                        child: Text('ОК'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
              splashColor: Colors.white.withOpacity(0.4),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          profile.member.nickname,
          style: TextStyle(
            fontSize: kFontSize * kGoldenRatio,
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.8),
          ),
        ),
        Text(
          getPluralKarma(profile.balance),
          style: TextStyle(
            // fontSize: kFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        // TODO: ещё надо отображать текущую замороженную Карму
        FlatButton(
          child: Text('ПОВЫСИТЬ КАРМУ'),
          onLongPress: () {}, // чтобы сократить время для splashColor
          onPressed: () {
            Navigator.of(context).pushNamed('/how_to_pay');
          },
          color: Colors.red,
          textColor: Colors.white,
        ),
        SizedBox(height: 16),
        Expanded(
          child: GlowNotificationWidget(
            ListView.separated(
              itemCount: _menu.length,
              itemBuilder: (BuildContext context, int index) {
                final entry = _menu[index];
                return Material(
                  child: InkWell(
                    child: ListTile(
                      title: index == 0
                          ? Text(
                              entry.value,
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            )
                          : Text(entry.value),
                      trailing: Icon(
                        Icons.navigate_next,
                        color: Colors.black.withOpacity(0.3),
                        size: kButtonIconSize,
                      ),
                    ),
                    onLongPress: () {}, // чтобы сократить время для splashColor
                    onTap: () {
                      Navigator.of(context).pushNamed(entry.key);
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
          ),
        ),
        if (widget.hasUpdate)
          Text('Доступна новая версия'),
        if (widget.hasUpdate)
          OutlineButton(
            // TODO: почему не установить цвет для OutlineButton
            // color: Colors.white,
            // textColor: Colors.pinkAccent,
            textColor: Colors.black.withOpacity(0.8),
            // TODO: Перезапустить
            child: Text('Обновить приложение'),
            onLongPress: () {}, // чтобы сократить время для splashColor
            onPressed: () {
              // TODO: go to update
              // https://medium.com/@naumanahmed19/prompt-update-app-dialog-in-flutter-application-4fe7a18f47f2
            },
          ),
        Text('Версия: ${widget.version}'),
        SizedBox(height: kNavigationBarHeight * 1.5 + 8),
      ],
    );
  }
}
