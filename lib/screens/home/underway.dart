import 'package:flutter/material.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:minsk8/import.dart';

class HomeUnderway extends StatelessWidget {
  static final homeKey = GlobalKey<HomeState>();
  static List<UnderwayData> dataPool;
  static final pullToRefreshNotificationKey =
      GlobalKey<PullToRefreshNotificationState>();
  static final poolForReloadTabs = <int>{}; // ie Set()

  @override
  Widget build(BuildContext context) {
    final child = Home(
      key: homeKey,
      tabModels: <UnderwayModel>[
        UnderwayModel(UnderwayValue.wish, 'Желаю'),
        UnderwayModel(UnderwayValue.want, 'Забираю'),
        // UnderwayModel(UnderwayValue.take, 'Забираю'),
        // UnderwayModel(UnderwayValue.past, 'Мимо'),
        UnderwayModel(UnderwayValue.give, 'Отдаю'),
      ],
      dataPool: dataPool,
      buildList: (int tabIndex, SourceList sourceList) {
        return ShowcaseList(
          tabIndex: tabIndex,
          sourceList: sourceList as SourceList<UnitModel>,
        );
      },
      pullToRefreshNotificationKey: pullToRefreshNotificationKey,
      poolForReloadTabs: poolForReloadTabs,
    );
    return SafeArea(
      child: child,
      bottom: false,
    );
  }
}
