import 'package:flutter/material.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:minsk8/import.dart';

class HomeUnderway extends StatelessWidget {
  HomeUnderway();

  static final showcaseKey = GlobalKey<ShowcaseState>();
  static List<UnderwayData> dataPool;
  static final pullToRefreshNotificationKey =
      GlobalKey<PullToRefreshNotificationState>();
  static final poolForReloadTabs = <int>{}; // ie Set()

  @override
  Widget build(BuildContext context) {
    final child = Showcase(
      key: showcaseKey,
      tabModels: <UnderwayModel>[
        UnderwayModel(UnderwayValue.wish, 'Желаю'),
        UnderwayModel(UnderwayValue.want, 'Забираю'),
        // UnderwayModel(UnderwayValue.take, 'Забираю'),
        // UnderwayModel(UnderwayValue.past, 'Мимо'),
        UnderwayModel(UnderwayValue.give, 'Отдаю'),
      ],
      dataPool: HomeUnderway.dataPool,
      pullToRefreshNotificationKey: HomeUnderway.pullToRefreshNotificationKey,
      poolForReloadTabs: HomeUnderway.poolForReloadTabs,
    );
    return SafeArea(child: child);
  }
}
