import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:minsk8/import.dart';

// TODO: https://github.com/faob-dev/folding_cell
// TODO: https://github.com/Ivaskuu/tinder_cards
// TODO: https://github.com/Dn-a/flutter_tags

// class ProfilePage extends StatefulWidget {
//   ProfilePage();

//   @override
//   ProfilePageState createState() {
//     return ProfilePageState();
//   }
// }

// class ProfilePageState extends State<ProfilePage> {
class ProfilePage extends StatelessWidget {
  ProfilePage({this.version});

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Container(
        //   height: 48,
        //   width: 48,
        //   child: ExtendedImage.network(
        //     member.avatarUrl,
        //     fit: BoxFit.cover,
        //     enableLoadState: false,
        //   ),
        // ),
        Text('сколько кармы'),
        Text('nick name'),
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
                    dense: true,
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
  }
}
