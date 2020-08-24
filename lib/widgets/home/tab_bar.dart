import 'package:flutter/material.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:minsk8/import.dart';

class HomeTabBar extends StatelessWidget {
  HomeTabBar({
    this.info,
    this.shrinkOffset,
    // this.overlapsContent,
    this.tabBar,
  });

  final PullToRefreshScrollNotificationInfo info;
  final double shrinkOffset;
  // final bool overlapsContent;
  final TabBar tabBar;

  @override
  Widget build(BuildContext context) {
    // TODO: поддерживать темную системную схему
    // TODO: Wrapper for overlayStyle
    // final AppBarTheme appBarTheme = AppBarTheme.of(context);
    // final Brightness brightness = appBarTheme.brightness;
    // final SystemUiOverlayStyle overlayStyle = brightness == Brightness.dark
    //     ? SystemUiOverlayStyle.light
    //     : SystemUiOverlayStyle.dark;
    // final child = AnnotatedRegion<SystemUiOverlayStyle>(
    //   value: overlayStyle,
    //   child:
    //   Material(
    //     elevation: kAppBarElevation,
    //     color: Colors.white,
    //     child: tabBar,
    //   ),
    // );
    final child = Material(
      elevation: kAppBarElevation,
      color: Colors.white,
      child: Center(child: tabBar),
    );
    // TODO: индикатор должен смещаться обратно наполовину, пока идёт загрузка
    // и это работает правильно у приложения Flutter Gallery
    final offset = info?.dragOffset ?? 0.0;
    return Stack(
      fit: StackFit.expand,
      overflow: Overflow.visible,
      children: <Widget>[
        Positioned(
          top: shrinkOffset + offset,
          left: 0,
          right: 0,
          child: Center(child: info?.refreshWiget),
        ),
        child,
      ],
    );
  }
}
