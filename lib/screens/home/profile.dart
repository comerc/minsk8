import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

// TODO: https://github.com/faob-dev/folding_cell
// TODO: https://github.com/Ivaskuu/tinder_cards
// TODO: https://github.com/Dn-a/flutter_tags

// TODO: текстовое поле для описания себя в профиле (усложняет модерацию)

// class HomeProfile extends StatefulWidget {
//   HomeProfile();

//   @override
//   HomeProfileState createState() {
//     return HomeProfileState();
//   }
// }

// class HomeProfileState extends State<HomeProfile> {
class HomeProfile extends StatelessWidget {
  HomeProfile({this.version});

  final String version;

  final _menu = {
    '/wallet': 'Движение Кармы',
    '/feedback': 'Обратная связь',
    '/faq': 'Вопросы и ответы',
    '/useful_tips': 'Полезные советы',
    '/about': 'О проекте',
  }.entries.toList();

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileModel>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 8),
        Container(
          width: 96,
          height: 96,
          child: Tooltip(
            message: 'Поменять аватарку',
            child: Material(
              elevation: kButtonElevation,
              type: MaterialType.circle,
              clipBehavior: Clip.hardEdge,
              color: Colors.white,
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
                child: Ink.image(
                  fit: BoxFit.cover,
                  image: ExtendedImage.network(
                    profile.member.avatarUrl,
                    enableLoadState: false,
                  ).image,
                ),
              ),
            ),
          ),
        ),
        Text('nick name'),
        Text('сколько кармы'),
        FlatButton(
          child: Text('ПОВЫСИТЬ КАРМУ'),
          onPressed: () {
            Navigator.of(context).pushNamed('/wallet');
          },
          color: Colors.red,
          textColor: Colors.white,
        ),
        Expanded(
          child: GlowNotificationWidget(
            ListView.separated(
              itemCount: _menu.length,
              itemBuilder: (BuildContext context, int index) {
                final entry = _menu[index];
                return InkWell(
                  child: ListTile(
                    title: Text(entry.value),
                    trailing: Icon(
                      Icons.navigate_next,
                      color: Colors.black.withOpacity(0.8),
                      size: kButtonIconSize,
                    ),
                    // dense: true,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(entry.key);
                  },
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
        Text('Версия: $version'),
        SizedBox(height: kNavigationBarHeight * 1.5 + 8),
      ],
    );

    // Stack(
    //   fit: StackFit.expand,
    //   children: [
    // Positioned(
    //   top: 96,
    //   left: 0,
    //   right: 0,
    //   child: Align(
    //     alignment: Alignment.center,
    //     child: Material(
    //       elevation: kButtonElevation,
    //       borderRadius: BorderRadius.all(
    //         Radius.circular(8),
    //       ),
    //       child: Container(
    //         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    //         decoration: BoxDecoration(
    //           color: Colors.white,
    //           // border: Border.all(
    //           //   color: Colors.grey.withOpacity(0.4),
    //           //   width: 1,
    //           // ),
    //           borderRadius: BorderRadius.all(
    //             Radius.circular(8),
    //           ),
    //         ),
    //         child: Text('сколько кармы'),
    //       ),
    //     ),
    //   ),
    // ),
    //   ],
    // );
  }
}
