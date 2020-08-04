import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

// TODO: променять везде AppBar на ExtendedAppBar

class ExtendedAppBar extends StatelessWidget implements PreferredSizeWidget {
  ExtendedAppBar({
    this.title,
    this.actions = const [],
    this.backgroundColor = Colors.white,
    this.elevation = kAppBarElevation, // ThemeData().appBarTheme.elevation,
  });

  final List<Widget> actions;
  final Widget title;
  final Color backgroundColor;
  final double elevation;

  @override
  final Size preferredSize = Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      iconTheme: IconThemeData(
        color: Colors.black.withOpacity(0.8),
      ),
      // TODO: должен появляться с анимацией, когда скролл уходит наверх
      // https://medium.com/@cezary.zelisko/flutter-how-to-design-an-appbar-with-variable-elevation-b3ffd38ac1eb
      elevation: elevation,
      excludeHeaderSemantics: true,
      titleSpacing: 0,
      title: title,
      actions: actions,
      // automaticallyImplyLeading: false,
      // title: Flex(
      //   direction: Axis.horizontal,
      //   children: [
      //     Tooltip(
      //       message: 'Close',
      //       child: ButtonTheme(
      //         minWidth: 0,
      //         padding: EdgeInsets.all((kToolbarHeight - kDefaultIconSize) / 2),
      //         child: FlatButton(
      //           onPressed: () {
      //             Navigator.maybePop(context);
      //           },
      //           shape: CircleBorder(),
      //           child: Icon(
      //             Icons.close,
      //             color: Colors.black.withOpacity(0.8),
      //             size: kDefaultIconSize,
      //           ),
      //         ),
      //       ),
      //     ),
      //     Expanded(child: Container(child: title)),
      //     ...actions,
      //   ],
      // ),
    );
  }
}
