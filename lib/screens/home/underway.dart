import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:minsk8/import.dart';

class HomeUnderway extends StatelessWidget {
  HomeUnderway({this.tabIndex});

  static final wrapperKey = GlobalKey<WrapperState>();
  static List<UnderwayData> dataPool;
  static final pullToRefreshNotificationKey =
      GlobalKey<PullToRefreshNotificationState>();
  static final poolForReloadTabs = <int>{}; // ie Set()

  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    final child = Wrapper(
      key: wrapperKey,
      tabIndex: tabIndex,
      tabsLength: UnderwayValue.values.length,
      getTabName: (int tabIndex) {
        return getUnderwayName(UnderwayValue.values[tabIndex]);
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
    );
    return SafeArea(
      bottom: false,
      child: child,
    );
  }
}

enum UnderwayValue {
  wish,
  want,
  // take,
  // past,
  give,
}

String getUnderwayName(UnderwayValue value) {
  final map = {
    UnderwayValue.wish: 'Желаю',
    UnderwayValue.want: 'Забираю',
    // UnderwayValue.take: 'Забираю',
    // UnderwayValue.past: 'Мимо',
    UnderwayValue.give: 'Отдаю',
  };
  assert(UnderwayValue.values.length == map.length);
  return map[value];
}
