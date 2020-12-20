// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
// import 'package:minsk8/import.dart';

part of '../home.dart';

class HomeShowcase extends StatelessWidget {
  HomeShowcase({this.pageIndex});

  static final pageWrapperKey = GlobalKey<PageWrapperState>();
  static List<ShowcaseData> dataPool;
  static final pullToRefreshNotificationKey =
      GlobalKey<PullToRefreshNotificationState>();
  static final poolForReloadTabs = <int>{}; // ie Set()

  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    final child = PageWrapper(
      key: pageWrapperKey,
      pageIndex: pageIndex,
      tabsLength: MetaKindValue.values.length + KindValue.values.length,
      getTabName: (int tabIndex) {
        if (tabIndex < MetaKindValue.values.length) {
          return getMetaKindName(MetaKindValue.values[tabIndex]);
        }
        return getKindName(
            KindValue.values[tabIndex - MetaKindValue.values.length]);
      },
      dataPool: dataPool,
      buildList: (int tabIndex) {
        return ShowcaseList(
          tagPrefix: '$pageIndex-$tabIndex',
          sourceList: dataPool[tabIndex],
        );
      },
      pullToRefreshNotificationKey: pullToRefreshNotificationKey,
      poolForReloadTabs: poolForReloadTabs,
      hasAppBar: true,
    );
    return SafeArea(
      bottom: false,
      child: child,
    );
  }
}
