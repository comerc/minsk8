import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

// TODO: променять везде AppBar на ExtendedAppBar

class ExtendedAppBar extends StatelessWidget implements PreferredSizeWidget {
  ExtendedAppBar({
    this.title,
    this.actions = const [],
    this.backgroundColor,
    this.elevation = kAppBarElevation, // ThemeData().appBarTheme.elevation,
  });

  final List<Widget> actions;
  final Widget title;
  final Color backgroundColor;
  final double elevation;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final appBarModel = Provider.of<AppBarModel>(context);
    return AppBar(
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      iconTheme: IconThemeData(
        color: Colors.black.withOpacity(0.8),
      ),
      textTheme: Theme.of(context)
          .primaryTextTheme
          .apply(bodyColor: Colors.black.withOpacity(0.8)),
      elevation: appBarModel.isElevation ? kAppBarElevation : 0,
      // excludeHeaderSemantics: true,
      // titleSpacing: 0,
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
