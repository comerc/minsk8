import 'package:flutter/material.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:minsk8/import.dart';

class HomeShowcase extends StatelessWidget {
  HomeShowcase();

  static final showcaseKey = GlobalKey<ShowcaseState>();
  static List<ShowcaseData> dataPool;
  static final pullToRefreshNotificationKey =
      GlobalKey<PullToRefreshNotificationState>();
  static final poolForReloadTabs = <int>{}; // ie Set()

  @override
  Widget build(BuildContext context) {
    final child = Showcase(
      key: showcaseKey,
      tabModels: kAllKinds,
      dataPool: HomeShowcase.dataPool,
      pullToRefreshNotificationKey: HomeShowcase.pullToRefreshNotificationKey,
      poolForReloadTabs: HomeShowcase.poolForReloadTabs,
      hasAppBar: true,
    );
    return SafeArea(child: child);
  }
}
