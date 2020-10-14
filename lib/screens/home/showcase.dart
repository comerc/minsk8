import 'package:minsk8/import.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';

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
      tabModels: kAllKinds,
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
