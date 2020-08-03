import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

// TODO: как добавить отступ для statusBarHeight? пока приходится вставлять в каждый экран

class ExtendedAppBar extends StatelessWidget implements PreferredSizeWidget {
  ExtendedAppBar({this.title, this.actions = const []});

  final List<Widget> actions;
  final Widget title;

  @override
  final Size preferredSize = Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      excludeHeaderSemantics: true,
      titleSpacing: 0,
      title: Flex(
        direction: Axis.horizontal,
        children: [
          Tooltip(
            message: 'Close',
            child: ButtonTheme(
              minWidth: 0,
              padding: EdgeInsets.all((kToolbarHeight - kDefaultIconSize) / 2),
              child: FlatButton(
                onPressed: () {
                  Navigator.maybePop(context);
                },
                shape: CircleBorder(),
                child: Icon(
                  Icons.close,
                  color: Colors.black.withOpacity(0.8),
                  size: kDefaultIconSize,
                ),
              ),
            ),
          ),
          Expanded(child: Container(child: title)),
          ...actions,
        ],
      ),
    );
  }
}
