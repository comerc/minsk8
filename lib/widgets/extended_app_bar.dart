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
  });

  final List<Widget> actions;
  final Widget title;
  final bool isForeground;
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
          isForeground ? Theme.of(context).dialogBackgroundColor : null,
      elevation: withModel ? (appBarModel.isElevation ? null : 0) : null,
      leading: leading,
      centerTitle: centerTitle,
      title: title,
      actions: actions,
    );
  }
}
