import 'package:flutter/material.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extended;
import 'package:minsk8/import.dart';

class Showcase extends StatefulWidget {
  Showcase({
    Key key,
    this.tabModels,
    this.dataPool,
    this.pullToRefreshNotificationKey,
    this.poolForReloadTabs,
    this.hasAppBar = false,
  }) : super(key: key);

  final List<EnumModel> tabModels;
  final List<SourceList> dataPool;
  final GlobalKey<PullToRefreshNotificationState> pullToRefreshNotificationKey;
  final Set<int> poolForReloadTabs;
  final bool hasAppBar;

  @override
  ShowcaseState createState() => ShowcaseState();
}

class ShowcaseState extends State<Showcase> with TickerProviderStateMixin {
  TabController _tabController;
  int get tabIndex => _tabController.index;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabModels.length,
      vsync: this,
    );
    _tabController.addListener(() {
      final sourceList = widget.dataPool[_tabController.index];
      if (!_tabController.indexIsChanging) {
        // print(
        //     'indexIsChanging ${sourceList.isLoadDataByTabChange} ${widget.tabModels[_tabController.index].value}');
        // если для категории еще не было загрузки (переходом по tab-у),
        // то добавление нового item-а в /add_item зря добавит tab в widget.poolForReloadTabs,
        // а потому удаление выполняю в любом случае, без оглядки на sourceList.isLoadDataByTabChange
        final isContaintsInPool =
            widget.poolForReloadTabs.remove(_tabController.index);
        if (sourceList.isLoadDataByTabChange) {
          if (_tabController.index > 0) {
            final sourceListBefore = widget.dataPool[_tabController.index - 1];
            sourceListBefore.resetIsLoadDataByTabChange();
          }
          sourceList.resetIsLoadDataByTabChange();
        } else if (isContaintsInPool) {
          // print('pullToRefreshNotificationKey');
          widget.pullToRefreshNotificationKey.currentState.show();
        }
      }
    });
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
      tabs: widget.tabModels
          .map((element) => Tab(text: element.enumName))
          .toList(),
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
      floatHeaderSlivers: widget.hasAppBar,
      physics: ClampingScrollPhysics(),
      pinnedHeaderSliverHeightBuilder: () => pinnedHeaderHeight,
      innerScrollPositionKeyBuilder: () => Key('${_tabController.index}'),
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => [
        if (widget.hasAppBar)
          SliverPersistentHeader(
            delegate: CommonSliverPersistentHeaderDelegate(
              builder: (BuildContext context, double shrinkOffset,
                  bool overlapsContent) {
                return ShowcaseAppBar();
              },
              height: kToolbarHeight,
            ),
          ),
        PullToRefreshContainer(
          (PullToRefreshScrollNotificationInfo info) {
            return SliverPersistentHeader(
              pinned: true,
              delegate: CommonSliverPersistentHeaderDelegate(
                builder: (BuildContext context, double shrinkOffset,
                    bool overlapsContent) {
                  return ShowcaseTabBar(
                    info: info,
                    shrinkOffset: shrinkOffset,
                    // overlapsContent: overlapsContent,
                    tabBar: tabBar,
                  );
                },
                height: tabBarHeight,
              ),
            );
          },
        ),
        // hack for https://github.com/fluttercandies/loading_more_list/issues/20
        SliverPersistentHeader(
          delegate: CommonSliverPersistentHeaderDelegate(
            builder: (BuildContext context, double shrinkOffset,
                bool overlapsContent) {
              return Container();
            },
            height: 16,
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: List.generate(
          widget.tabModels.length,
          (index) => ShowcaseList(
            tabIndex: index,
            sourceList: widget.dataPool[index],
          ),
        ),
      ),
    );
    return PullToRefreshNotification(
      key: widget.pullToRefreshNotificationKey,
      onRefresh: _onRefresh,
      maxDragOffset: kMaxDragOffset,
      child: child,
    );
  }

  Future<bool> _onRefresh() async {
    // print('onRefresh');
    final sourceList = widget.dataPool[_tabController.index];
    return await sourceList.handleRefresh();
  }
}
