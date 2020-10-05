import 'package:minsk8/import.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';

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
      tabModels: <UnderwayModel>[
        UnderwayModel(UnderwayValue.wish, 'Желаю'),
        UnderwayModel(UnderwayValue.want, 'Забираю'),
        // UnderwayModel(UnderwayValue.take, 'Забираю'),
        // UnderwayModel(UnderwayValue.past, 'Мимо'),
        UnderwayModel(UnderwayValue.give, 'Отдаю'),
      ],
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
      child: child,
      bottom: false,
    );
  }
}
