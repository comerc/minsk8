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
    this.withModel = false,
    this.leading,
    this.centerTitle = false,
  });

  final List<Widget> actions;
  final Widget title;
  final Color backgroundColor;
  final double elevation;
  final Widget leading;
  final bool withModel;
  final bool centerTitle;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final appBarModel = withModel ? Provider.of<AppBarModel>(context) : null;
    return AppBar(
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      iconTheme: IconThemeData(
        color: Colors.black.withOpacity(0.8),
      ),
      textTheme: Theme.of(context)
          .primaryTextTheme
          .apply(bodyColor: Colors.black.withOpacity(0.8)),
      elevation:
          withModel ? (appBarModel.isElevation ? elevation : 0) : elevation,
      // excludeHeaderSemantics: true,
      // titleSpacing: 0,
      leading: leading,
      centerTitle: centerTitle,
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
