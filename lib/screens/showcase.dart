import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extended;
import 'package:minsk8/import.dart';

class ShowcaseScreen extends StatefulWidget {
  static final pullToRefreshNotificationKey =
      GlobalKey<PullToRefreshNotificationState>();
  static final poolForReloadTabs = <int>[];

  @override
  _ShowcaseScreenState createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen>
    with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _initDynamicLinks();
    _tabController = TabController(length: allKinds.length, vsync: this);
    _tabController.addListener(() {
      final sourceList = sourceListPool[_tabController.index];
      if (!_tabController.indexIsChanging) {
        // print(
        //     'indexIsChanging ${sourceList.isLoadDataByTabChange} ${allKinds[_tabController.index].enumValue}');

        // если для категории еще не было загрузки (переходом по tab-у),
        // то добавление нового item-а в /add_item зря добавит tab в ShowcaseScreen.poolForReloadTabs,
        // а потому удаление выполняю в любом случае, без оглядки на sourceList.isLoadDataByTabChange
        final isContaintsInPool =
            ShowcaseScreen.poolForReloadTabs.remove(_tabController.index);
        if (sourceList.isLoadDataByTabChange) {
          if (_tabController.index > 0) {
            final sourceListBefore = sourceListPool[_tabController.index - 1];
            sourceListBefore.resetIsLoadDataByTabChange();
          }
          sourceList.resetIsLoadDataByTabChange();
        } else if (isContaintsInPool) {
          // print('pullToRefreshNotificationKey');
          ShowcaseScreen.pullToRefreshNotificationKey.currentState.show();
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
      tabs: allKinds.map((kind) => Tab(text: kind.name)).toList(),
    );
    final tabBarHeight = tabBar.preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final pinnedHeaderHeight =
        // statusBar height
        statusBarHeight +
            // pinned SliverAppBar height in header
            kToolbarHeight +
            // pinned tabbar height in header
            tabBarHeight +
            // TODO: ??? если потянуть список вниз и вверх, то он наплывает на табы
            44;
    return Scaffold(
      drawer: MainDrawer('/showcase'),
      body: PullToRefreshNotification(
        key: ShowcaseScreen.pullToRefreshNotificationKey,
        color: Colors.blue,
        pullBackOnRefresh: true,
        onRefresh: _onRefresh,
        maxDragOffset: 100,
        child: extended.NestedScrollView(
          physics: ClampingScrollPhysics(),
          pinnedHeaderSliverHeightBuilder: () => pinnedHeaderHeight,
          innerScrollPositionKeyBuilder: () =>
              Key(allKinds[_tabController.index].name),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            PullToRefreshContainer(_buildAppBar),
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: CommonSliverPersistentHeaderDelegate(
                Container(
                  child: tabBar,
                  // color: Colors.white,
                ),
                tabBarHeight,
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: List.generate(
              allKinds.length,
              (index) => ShowcaseList(tabIndex: index),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: buildAddButton(
        context,
        getTabIndex: () => _tabController.index,
      ),
      bottomNavigationBar: NavigationBar(currentRouteName: '/showcase'),
      extendBody: true,
    );
  }

  Widget _buildAppBar(PullToRefreshScrollNotificationInfo info) {
    // Widget action = Padding(
    //   child: info?.refreshWiget ?? Icon(Icons.more_horiz),
    //   padding: EdgeInsets.all(15),
    // );
    final offset = info?.dragOffset ?? 0.0;
    // Widget child = Container();
    // if (info != null) {
    //   if (info.mode == RefreshIndicatorMode.error) {
    //     child = GestureDetector(
    //       onTap: () {
    //         // refreshNotification;
    //         info?.pullToRefreshNotificationState?.show();
    //       },
    //       child: Text(
    //         (info.mode?.toString() ?? '') + " click to retry" ?? '',
    //         style: TextStyle(fontSize: 10),
    //       ),
    //     );
    //     action = Container();
    //   } else {
    //     // child = Text(
    //     //   info?.mode?.toString() ?? '',
    //     //   style: TextStyle(fontSize: 10),
    //     // );
    //   }
    // }
    return SliverAppBar(
      pinned: true,
      title: Text('Showcase'),
      centerTitle: true,
      // expandedHeight: 200 + offset,
      expandedHeight: offset,
      // actions: [action],
      // flexibleSpace: FlexibleSpaceBar(
      //   //centerTitle: true,
      //   title: child,
      //   collapseMode: CollapseMode.pin,
      //   background: Image.asset(
      //     "assets/467141054.jpg",
      //     //fit: offset > 0 ? BoxFit.cover : BoxFit.fill,
      //     fit: BoxFit.cover,
      //   ),
      // ),
    );
  }

  Future<bool> _onRefresh() async {
    // print('onRefresh');
    final sourceList = sourceListPool[_tabController.index];
    return await sourceList.handleRefresh(true);
  }

  void _initDynamicLinks() async {
    final data = await FirebaseDynamicLinks.instance.getInitialLink();
    _openDeepLink(data?.link);
    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData data) async {
        _openDeepLink(data?.link);
      },
      onError: (OnLinkErrorException error) async {
        // print('onLinkError');
        print(error.message);
      },
    );
  }

  void _openDeepLink(Uri link) {
    if (link == null) return;
    if (link.path == '/item') {
      // TODO: Queries.getItem
      // final id = link.queryParameters['id'];
      // Navigator.pushNamed(
      //   context,
      //   '/item',
      //   arguments: ItemRouteArguments(id),
      // );
    }
  }
}

class CommonSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  CommonSliverPersistentHeaderDelegate(this.child, this.height);

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(CommonSliverPersistentHeaderDelegate oldDelegate) {
    //print("shouldRebuild---------------");
    return oldDelegate != this;
  }
}
