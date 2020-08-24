import 'package:flutter/material.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:minsk8/import.dart';

class HomeShowcase extends StatelessWidget {
  static final wrapperKey = GlobalKey<WrapperState>();
  static List<ShowcaseData> dataPool;
  static final pullToRefreshNotificationKey =
      GlobalKey<PullToRefreshNotificationState>();
  static final poolForReloadTabs = <int>{}; // ie Set()

  @override
  Widget build(BuildContext context) {
    final child = Wrapper(
      key: wrapperKey,
      tabModels: kAllKinds,
      dataPool: dataPool,
      buildList: (int tabIndex, SourceList sourceList) {
        return ShowcaseList(
          tabIndex: tabIndex,
          sourceList: sourceList as SourceList<UnitModel>,
        );
      },
      pullToRefreshNotificationKey: pullToRefreshNotificationKey,
      poolForReloadTabs: poolForReloadTabs,
      hasAppBar: true,
    );
    return SafeArea(
      child: child,
      bottom: false,
    );
  }
}
