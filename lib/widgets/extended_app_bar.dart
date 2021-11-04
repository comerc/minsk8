import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

class ExtendedAppBar extends StatelessWidget implements PreferredSizeWidget {
  ExtendedAppBar({
    this.title,
    this.actions = const [],
    this.isForeground = false,
    this.withModel = false,
    this.leading,
    this.centerTitle = false,
    this.elevation,
  });

  final List<Widget> actions;
  final Widget title;
  final bool isForeground;
  final Widget leading;
  final bool withModel;
  final bool centerTitle;
  final double elevation;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final appBarModel = withModel ? Provider.of<AppBarModel>(context) : null;
    return AppBar(
      // automaticallyImplyLeading: false, // TODO: [MVP] костыль для VersionCubit (#638)
      backgroundColor:
          isForeground ? Theme.of(context).dialogBackgroundColor : null,
      elevation:
          withModel ? (appBarModel.isElevation ? elevation : 0) : elevation,
      leading: leading,
      centerTitle: centerTitle,
      title: title,
      actions: actions,
    );
  }
}
