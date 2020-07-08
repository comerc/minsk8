import 'package:flutter/material.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:minsk8/import.dart';

class ListTabBar extends StatelessWidget {
  ListTabBar({
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
    final offset = info?.dragOffset ?? 0.0;
    return Stack(
      fit: StackFit.expand,
      overflow: Overflow.visible,
      children: [
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
