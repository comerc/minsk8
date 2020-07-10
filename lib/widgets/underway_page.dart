import 'package:flutter/material.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:minsk8/import.dart';

class UnderwayPage extends StatelessWidget {
  UnderwayPage({
    this.showcaseKey,
  });

  final Key showcaseKey;
  static List<UnderwayData> dataPool;
  static final pullToRefreshNotificationKey =
      GlobalKey<PullToRefreshNotificationState>();
  static final poolForReloadTabs = Set<int>();

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: showcaseKey,
      tabModels: [
        UnderwayModel(UnderwayValue.wish, 'Желаю'),
        UnderwayModel(UnderwayValue.want, 'Забираю'),
        // UnderwayModel(UnderwayValue.take, 'Забираю'),
        // UnderwayModel(UnderwayValue.past, 'Мимо'),
        UnderwayModel(UnderwayValue.give, 'Отдаю'),
      ],
      dataPool: UnderwayPage.dataPool,
      pullToRefreshNotificationKey: UnderwayPage.pullToRefreshNotificationKey,
      poolForReloadTabs: UnderwayPage.poolForReloadTabs,
    );
  }
}
