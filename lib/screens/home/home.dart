import 'package:minsk8/import.dart';

enum HomeTabValue { showcase, underway, interplay, profile }

class HomeScreen extends StatefulWidget {
  HomeScreen() : super(key: globalKey);

  static final globalKey = GlobalKey<_HomeScreenState>();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController _pageController;
  int _tabIndex = HomeTabValue.showcase.index;
  // int _tabIndex = HomeTabValue.interplay.index;
  int get tabIndex => _tabIndex;
  int get _subTabIndex => [
        HomeShowcase.wrapperKey.currentState?.tabIndex,
        HomeUnderway.wrapperKey.currentState?.tabIndex,
        null,
        null,
      ][_tabIndex];
  String get tagPrefix => '$_tabIndex-$_subTabIndex';
  bool _hasUpdate;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _tabIndex);
    final version = Provider.of<VersionModel>(context, listen: false);
    version.init();
    // TODO: [MVP] реализовать hasUpdate
    _hasUpdate = isInDebugMode;
    analytics.setCurrentScreen(screenName: '/home');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: isInDebugMode ? MainDrawer(null) : null,
      // это не нужно при использвании SafeArea
      // appBar: PreferredSize(
      //   child: Container(
      //     color: Colors.white,
      //   ),
      //   preferredSize: Size.zero, // hack
      // ),
      // body: IndexedStack(
      //   children: <Widget>[
      //     HomeShowcase(tabIndex: 0),
      //     HomeUnderway(tabIndex: 1),
      //     HomeInterplay(tabIndex: 2),
      //     HomeProfile(hasUpdate: _hasUpdate),
      //   ],
      //   index: _tabIndex,
      // ),
      // body: <Widget>[
      //   HomeShowcase(tabIndex: 0),
      //   HomeUnderway(tabIndex: 1),
      //   HomeInterplay(tabIndex: 2),
      //   HomeProfile(hasUpdate: _hasUpdate),
      // ][_tabIndex],
      // see here: https://developpaper.com/three-ways-to-keep-the-state-of-the-original-page-after-page-switching-by-flutter/
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: <Widget>[
          HomeShowcase(tabIndex: 0),
          HomeUnderway(tabIndex: 1),
          HomeInterplay(tabIndex: 2),
          HomeProfile(hasUpdate: _hasUpdate),
        ],
        physics: NeverScrollableScrollPhysics(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildAddButton(),
      bottomNavigationBar: _NavigationBar(
        tabIndex: _tabIndex,
        onChangeTabIndex: _pageController.jumpToPage,
      ),
      extendBody: true,
    );
  }

  void _onPageChanged(int value) {
    setState(() {
      _tabIndex = value;
    });
  }

  Future<void> initDynamicLinks() async {
    final data = await FirebaseDynamicLinks.instance.getInitialLink();
    // for StartScreen
    // ignore: unawaited_futures
    _openDeepLink(data?.link).then((UnitRouteArguments arguments) {
      if (arguments == null) {
        Navigator.of(context).pop();
        return;
      }
      Navigator.pushReplacement(
        context,
        buildRoute(
          '/unit',
          builder: (_) => UnitScreen(
            arguments.unit,
            member: arguments.member,
            isShowcase: arguments.isShowcase,
          ),
          fullscreenDialog: true,
        ),
      );
    }).catchError((error) {
      debugPrint(error.toString());
      Navigator.of(context).pop();
    });
    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData data) async {
        final arguments = await _openDeepLink(data?.link);
        if (arguments == null) {
          return;
        }
        // ignore: unawaited_futures
        Navigator.push(
          context,
          buildRoute(
            '/unit',
            builder: (_) => UnitScreen(
              arguments.unit,
              member: arguments.member,
              isShowcase: arguments.isShowcase,
            ),
            fullscreenDialog: true,
          ),
        );
      },
      onError: (OnLinkErrorException error) async {
        debugPrint(error.message);
      },
    );
  }

  Future<UnitRouteArguments> _openDeepLink(Uri link) async {
    if (link == null || link.path != '/unit') return null;
    final id = link.queryParameters['id'];
    final options = QueryOptions(
      documentNode: Queries.getUnit,
      variables: {'id': id},
      fetchPolicy: FetchPolicy.noCache,
    );
    // final client = GraphQLProvider.of(context).value;
    try {
      final result =
          await client.query(options).timeout(kGraphQLQueryTimeoutDuration);
      if (result.hasException) {
        throw result.exception;
      }
      final unit =
          UnitModel.fromJson(result.data['unit'] as Map<String, dynamic>);
      return UnitRouteArguments(
        unit,
        member: unit.member,
        isShowcase: true,
      );
    } catch (error, stack) {
      print(error);
      print(stack);
    }
    return null;
  }

  Widget _buildAddButton() {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      foregroundColor: Colors.pinkAccent,
      onPressed: () async {
        final kind = await Navigator.push<KindValue>(
          context,
          buildRoute(
            '/kinds',
            builder: (_) => KindsScreen(),
            fullscreenDialog: true,
          ),
        ); // as KindValue; // workaround for typecast
        if (kind == null) return;
        // ignore: unawaited_futures
        Navigator.push(
          context,
          buildRoute(
            '/add_unit',
            builder: (_) => AddUnitScreen(
              kind: kind,
              tabIndex: AddUnitTabIndex(
                showcase: HomeShowcase.wrapperKey.currentState?.tabIndex,
                underway: HomeUnderway.wrapperKey.currentState?.tabIndex,
              ),
            ),
            fullscreenDialog: true,
          ),
        );
      },
      tooltip: 'Add Unit',
      child: Icon(
        Icons.add,
        size: kBigButtonIconSize * 1.2,
      ),
      elevation: kButtonElevation,
    );
  }
}

typedef _NavigationBarOnChangeTabIndex = void Function(int tabIndex);

class _NavigationBar extends StatelessWidget {
  _NavigationBar({this.tabIndex, this.onChangeTabIndex});

  final int tabIndex;
  final _NavigationBarOnChangeTabIndex onChangeTabIndex;
  final double _height = kNavigationBarHeight;
  final Color _backgroundColor = Colors.white;
  final Color _color = Colors.grey;
  final Color _selectedColor = Colors.pinkAccent;
  final _tabs = [
    _NavigationBarTab(
      title: 'Showcase',
      icon: Icons.home,
      value: _NavigationBarTabValue.showcase,
    ),
    _NavigationBarTab(
      title: 'Underway',
      icon: Icons.widgets, // Icons.queue,
      value: _NavigationBarTabValue.underway,
    ),
    _NavigationBarTab(
      title: 'Chat',
      icon: Icons.chat,
      value: _NavigationBarTabValue.chat,
    ),
    _NavigationBarTab(
      title: 'Profile',
      icon: Icons.account_box,
      value: _NavigationBarTabValue.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final children = List.generate(
      _tabs.length,
      (int index) => _buildTabUnit(
        context: context,
        index: index,
        isSelected: index == tabIndex,
      ),
    );
    children.insert(children.length >> 1, _buildMiddleTabUnit());
    return BottomAppBar(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: children,
      ),
      shape: CircularNotchedRectangle(),
      clipBehavior: Clip.hardEdge,
      notchMargin: 8,
      color: _backgroundColor,
    );
  }

  Widget _buildMiddleTabUnit() {
    return Expanded(
      child: SizedBox(
        height: _height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: kBigButtonIconSize),
          ],
        ),
      ),
    );
  }

  Widget _buildTabUnit({
    BuildContext context,
    int index,
    bool isSelected,
  }) {
    final tab = _tabs[index];
    final color = isSelected ? _selectedColor : _color;
    return Expanded(
      child: SizedBox(
        height: _height,
        child: Tooltip(
          message: tab.title,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () {
                onChangeTabIndex(index);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    tab.icon,
                    color: color,
                    size: kBigButtonIconSize,
                  ),
                  // Text(
                  //   tab.title,
                  //   style: TextStyle(color: color),
                  // )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _NavigationBarTabValue { showcase, underway, chat, profile }

class _NavigationBarTab {
  _NavigationBarTab({this.title, this.icon, this.value});

  String title;
  IconData icon;
  _NavigationBarTabValue value;
}
