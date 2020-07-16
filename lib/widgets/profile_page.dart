import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:provider/provider.dart';
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
    final profile = Provider.of<ProfileModel>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 8),
        // TODO: InkWell, но Ink.image не умеет делать круглую картинку
        // https://medium.com/@RayLiVerified/create-a-rounded-image-icon-with-ripple-effect-in-flutter-eb0f4a720b90
        // https://stackoverflow.com/questions/55565865/create-circle-button-with-network-image-and-ripple-effect
        // https://www.codegrepper.com/code-examples/dart/ink+image+clip+flutter
        Material(
          shape: CircleBorder(),
          color: Colors.white,
          child: ExtendedImage.network(
            profile.member.avatarUrl,
            width: 96,
            height: 96,
            shape: BoxShape.circle,
            fit: BoxFit.cover,
            enableLoadState: false,
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
