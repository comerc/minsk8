import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:minsk8/import.dart';

class HomeShowcase extends StatelessWidget {
  HomeShowcase({this.tabIndex});

  static final wrapperKey = GlobalKey<WrapperState>();
  static List<ShowcaseData> dataPool;
  static final pullToRefreshNotificationKey =
      GlobalKey<PullToRefreshNotificationState>();
  static final poolForReloadTabs = <int>{}; // ie Set()

  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    final child = Wrapper(
      key: wrapperKey,
      tabIndex: tabIndex,
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
          tagPrefix: '${this.tabIndex}-$tabIndex',
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
