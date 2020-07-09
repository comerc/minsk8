import 'package:flutter/material.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extended;
import 'package:minsk8/import.dart';

class Underway extends StatefulWidget {
  @override
  UnderwayState createState() => UnderwayState();
}

class UnderwayState extends State<Underway> with TickerProviderStateMixin {
  TabController _tabController;
  final List<UnderwayTab> _tabs = [
    UnderwayTab(UnderwayTabValue.wish, 'Желаю'),
    UnderwayTab(UnderwayTabValue.want, 'Забираю'),
    UnderwayTab(UnderwayTabValue.past, 'Мимо'),
    UnderwayTab(UnderwayTabValue.give, 'Отдаю'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabBar = TabBar(
      controller: _tabController,
      labelColor: Colors.blue,
      indicatorColor: Colors.blue,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorWeight: 2,
      unselectedLabelColor: Colors.grey,
      isScrollable: true,
      tabs: _tabs.map((tab) => Tab(text: tab.name)).toList(),
    );
    final tabBarHeight = tabBar.preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final pinnedHeaderHeight =
        // pinned statusBar height
        statusBarHeight +
            // pinned SliverAppBar height in header
            // kToolbarHeight +
            // pinned tabbar height in header
            tabBarHeight;
    final child = extended.NestedScrollView(
      floatHeaderSlivers: true,
      physics: ClampingScrollPhysics(),
      pinnedHeaderSliverHeightBuilder: () => pinnedHeaderHeight,
      innerScrollPositionKeyBuilder: () => Key('${_tabController.index}'),
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverPersistentHeader(
          pinned: true,
          delegate: CommonSliverPersistentHeaderDelegate(
            builder: (BuildContext context, double shrinkOffset,
                bool overlapsContent) {
              return SizedBox(height: statusBarHeight);
            },
            height: statusBarHeight,
          ),
        ),
        PullToRefreshContainer(
          (PullToRefreshScrollNotificationInfo info) => SliverPersistentHeader(
            pinned: true,
            delegate: CommonSliverPersistentHeaderDelegate(
              builder: (BuildContext context, double shrinkOffset,
                  bool overlapsContent) {
                return ListTabBar(
                  info: info,
                  shrinkOffset: shrinkOffset,
                  // overlapsContent: overlapsContent,
                  tabBar: tabBar,
                );
              },
              height: tabBarHeight,
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: List.generate(
          _tabs.length,
          (index) => UnderwayList(tabIndex: index),
        ),
      ),
    );
    return PullToRefreshNotification(
      onRefresh: _onRefresh,
      maxDragOffset: 100,
      child: child,
    );
  }

  Future<bool> _onRefresh() async {
    // print('onRefresh');
    // final showcaseData = showcaseDataPool[_tabController.index];
    // return await showcaseData.handleRefresh();
    return true;
  }
}

enum UnderwayTabValue { wish, want, give, past }

class UnderwayTab {
  UnderwayTab(this.value, this.name);
  final UnderwayTabValue value;
  final String name;
}

class UnderwayList extends StatefulWidget {
  UnderwayList({
    Key key,
    this.tabIndex,
  })  : scrollPositionKey = Key('$tabIndex'),
        // showcaseData = showcaseDataPool[tabIndex],
        super(key: key);

  final Key scrollPositionKey;
  // final ShowcaseData showcaseData;
  final int tabIndex;

  @override
  _UnderwayListState createState() => _UnderwayListState();
}

class _UnderwayListState extends State<UnderwayList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Text(widget.scrollPositionKey.toString()),
    );
  }
}
