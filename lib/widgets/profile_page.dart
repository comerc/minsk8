import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:minsk8/import.dart';

// TODO: https://github.com/faob-dev/folding_cell
// TODO: https://github.com/Ivaskuu/tinder_cards
// TODO: https://github.com/Dn-a/flutter_tags

const menu = ['1111', '2222', '3333', '4444'];

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlowNotificationWidget(ListView.separated(
      itemCount: menu.length,
      itemBuilder: (context, index) {
        return InkWell(
          child: ListTile(
            title: Text(menu[index]),
            trailing: Icon(
              Icons.navigate_next,
              color: Colors.black.withOpacity(0.8),
              size: kButtonIconSize,
            ),
            dense: true,
          ),
          onTap: () {},
        );
      },
      separatorBuilder: (context, index) {
        return Divider(
          indent: 16,
          endIndent: 16,
          height: 1,
        );
      },
    ));
  }
}
