import 'package:flutter/material.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:minsk8/import.dart';

class ShowcasePage extends StatelessWidget {
  ShowcasePage({
    this.showcaseKey,
  });

  final Key showcaseKey;
  static List<ShowcaseData> dataPool;
  static final pullToRefreshNotificationKey =
      GlobalKey<PullToRefreshNotificationState>();
  static final poolForReloadTabs = Set<int>();

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: showcaseKey,
      tabModels: allKinds,
      dataPool: ShowcasePage.dataPool,
      pullToRefreshNotificationKey: ShowcasePage.pullToRefreshNotificationKey,
      poolForReloadTabs: ShowcasePage.poolForReloadTabs,
      hasAppBar: true,
    );
  }
}
