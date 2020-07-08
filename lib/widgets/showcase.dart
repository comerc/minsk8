import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extended;
import 'package:minsk8/import.dart';

typedef ShowcaseOnChangeTabIndex = void Function(int tabIndex);

class Showcase extends StatefulWidget {
  Showcase({
    this.tabIndex,
    this.onChangeTabIndex,
  });

  static final pullToRefreshNotificationKey =
      GlobalKey<PullToRefreshNotificationState>();
  static final poolForReloadTabs = Set<int>();

  final int tabIndex;
  final ShowcaseOnChangeTabIndex onChangeTabIndex;

  @override
  ShowcaseState createState() => ShowcaseState();
}

class ShowcaseState extends State<Showcase> with TickerProviderStateMixin {
  TabController _tabController;
  int get tabIndex => _tabController.index;

  @override
  void initState() {
    super.initState();
    _initDynamicLinks();
    _tabController = TabController(
      initialIndex: widget.tabIndex,
      length: allKinds.length,
      vsync: this,
    );
    _tabController.addListener(() {
      final sourceList = sourceListPool[_tabController.index];
      if (!_tabController.indexIsChanging) {
        widget.onChangeTabIndex(_tabController.index);
        // print(
        //     'indexIsChanging ${sourceList.isLoadDataByTabChange} ${allKinds[_tabController.index].enumValue}');
        // если для категории еще не было загрузки (переходом по tab-у),
        // то добавление нового item-а в /add_item зря добавит tab в Showcase.poolForReloadTabs,
        // а потому удаление выполняю в любом случае, без оглядки на sourceList.isLoadDataByTabChange
        final isContaintsInPool =
            Showcase.poolForReloadTabs.remove(_tabController.index);
        if (sourceList.isLoadDataByTabChange) {
          if (_tabController.index > 0) {
            final sourceListBefore = sourceListPool[_tabController.index - 1];
            sourceListBefore.resetIsLoadDataByTabChange();
          }
          sourceList.resetIsLoadDataByTabChange();
        } else if (isContaintsInPool) {
          // print('pullToRefreshNotificationKey');
          Showcase.pullToRefreshNotificationKey.currentState.show();
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
        // pinned statusBar height
        statusBarHeight +
            // pinned SliverAppBar height in header
            // kToolbarHeight +
            // pinned tabbar height in header
            tabBarHeight;
    final child = extended.NestedScrollView(
      // TODO: floatHeaderSlivers: true https://github.com/fluttercandies/extended_nested_scroll_view/issues/38
      physics: ClampingScrollPhysics(),
      pinnedHeaderSliverHeightBuilder: () => pinnedHeaderHeight,
      innerScrollPositionKeyBuilder: () =>
          Key(allKinds[_tabController.index].name),
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
          (PullToRefreshScrollNotificationInfo info) => SliverPersistentHeader(
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
    );
    return PullToRefreshNotification(
      key: Showcase.pullToRefreshNotificationKey,
      onRefresh: _onRefresh,
      maxDragOffset: 100,
      child: child,
    );
  }

  // Widget _buildAppBar(PullToRefreshScrollNotificationInfo info) {
  //   // Widget action = Padding(
  //   //   child: info?.refreshWiget ?? Icon(Icons.more_horiz),
  //   //   padding: EdgeInsets.all(15),
  //   // );
  //   final offset = info?.dragOffset ?? 0.0;
  //   // Widget child = Container();
  //   // if (info != null) {
  //   //   if (info.mode == RefreshIndicatorMode.error) {
  //   //     child = GestureDetector(
  //   //       onTap: () {
  //   //         // refreshNotification;
  //   //         info?.pullToRefreshNotificationState?.show();
  //   //       },
  //   //       child: Text(
  //   //         (info.mode?.toString() ?? '') + " click to retry" ?? '',
  //   //         style: TextStyle(fontSize: 10),
  //   //       ),
  //   //     );
  //   //     action = Container();
  //   //   } else {
  //   //     child = Text(
  //   //       info?.mode?.toString() ?? '',
  //   //       style: TextStyle(fontSize: 10),
  //   //     );
  //   //   }
  //   // }
  //   return SliverAppBar(
  //     pinned: true,
  //     title: Text('Showcase'),
  //     centerTitle: true,
  //     // expandedHeight: 200 + offset,
  //     expandedHeight: offset,
  //     // actions: [action],
  //     // flexibleSpace: FlexibleSpaceBar(
  //     //   //centerTitle: true,
  //     //   title: child,
  //     //   collapseMode: CollapseMode.pin,
  //     //   background: Image.asset(
  //     //     "assets/467141054.jpg",
  //     //     //fit: offset > 0 ? BoxFit.cover : BoxFit.fill,
  //     //     fit: BoxFit.cover,
  //     //   ),
  //     // ),
  //   );
  // }

  Future<bool> _onRefresh() async {
    // print('onRefresh');
    final sourceList = sourceListPool[_tabController.index];
    return await sourceList.handleRefresh();
  }

  Future<void> _initDynamicLinks() async {
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

  Future<void> _openDeepLink(Uri link) async {
    if (link == null || link.path != '/item') return;
    final id = link.queryParameters['id'];
    final options = QueryOptions(
      documentNode: Queries.getItem,
      variables: {'id': id},
      fetchPolicy: FetchPolicy.noCache,
    );
    final client = GraphQLProvider.of(context).value;
    final result = await client
        .query(options)
        .timeout(Duration(seconds: kGraphQLQueryTimeout));
    if (result.hasException) {
      throw result.exception;
    }
    final item = ItemModel.fromJson(result.data['item']);
    final arguments = ItemRouteArguments(
      item,
      member: item.member,
    );
    Navigator.pushNamed(
      context,
      '/item',
      arguments: arguments,
    );
  }
}

typedef Widget CommonSliverPersistentHeaderDelegateBuilder(
    BuildContext context, double shrinkOffset, bool overlapsContent);

class CommonSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  final double height;
  final CommonSliverPersistentHeaderDelegateBuilder builder;

  CommonSliverPersistentHeaderDelegate({this.builder, this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return builder(context, shrinkOffset, overlapsContent);
  }

  @override
  bool shouldRebuild(CommonSliverPersistentHeaderDelegate oldDelegate) {
    // TODO: оптимизировать
    return oldDelegate != this;
  }
}

class ShowcaseAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  'Без названия',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  "${appState['mainAddress']} — ${appState['radius'].toInt()} км",
                  style: TextStyle(
                    fontSize: kFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
          Spacer(),
          AspectRatio(
            aspectRatio: 1,
            child: Tooltip(
              message: 'Настройки витрины',
              child: Material(
                color: Colors.white,
                child: InkWell(
                  borderRadius:
                      BorderRadius.all(Radius.circular(kButtonIconSize * 2)),
                  child: Container(
                    child: Icon(
                      FontAwesomeIcons.slidersH,
                      color: Colors.black.withOpacity(0.8),
                      size: kButtonIconSize,
                    ),
                  ),
                  onTap: () {}, // TODO: /settings
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShowcaseTabBar extends StatelessWidget {
  ShowcaseTabBar({
    this.info,
    this.shrinkOffset,
    // this.overlapsContent,
    this.tabBar,
  });

  final PullToRefreshScrollNotificationInfo info;
  final double shrinkOffset;
  // final bool overlapsContent;
  final TabBar tabBar;

  @override
  Widget build(BuildContext context) {
    // TODO: Wrapper for overlayStyle
    // final AppBarTheme appBarTheme = AppBarTheme.of(context);
    // final Brightness brightness = appBarTheme.brightness;
    // final SystemUiOverlayStyle overlayStyle = brightness == Brightness.dark
    //     ? SystemUiOverlayStyle.light
    //     : SystemUiOverlayStyle.dark;
    // final child = AnnotatedRegion<SystemUiOverlayStyle>(
    //   value: overlayStyle,
    //   child:
    //   Material(
    //     elevation: kAppBarElevation,
    //     color: Colors.white,
    //     child: tabBar,
    //   ),
    // );
    final child = Material(
      elevation: kAppBarElevation,
      color: Colors.white,
      child: tabBar,
    );
    final offset = info?.dragOffset ?? 0.0;
    return Stack(
      fit: StackFit.expand,
      overflow: Overflow.visible,
      children: [
        Positioned(
          top: shrinkOffset + offset,
          left: 0,
          right: 0,
          child: Center(child: info?.refreshWiget),
        ),
        child,
      ],
    );
  }
}
