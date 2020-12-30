import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:state_persistence/state_persistence.dart';
import 'package:provider/provider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:intl/intl.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extended;
import 'package:minsk8/import.dart';

part 'home/interplay.dart';
part 'home/profile.dart';
part 'home/showcase.dart';
part 'home/underway.dart';

// TODO: переопределить WillPop для HomeScreen?
// TODO: переименовать HomeScreen > DashboardScreen

enum HomeTabValue { showcase, underway, interplay, profile }

class HomeScreen extends StatefulWidget {
  Route<T> getRoute<T>() {
    return buildRoute<T>(
      '/home',
      builder: (_) => this,
    );
  }

  HomeScreen() : super(key: globalKey);

  static final globalKey = GlobalKey<_HomeScreenState>();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController _pageController;
  int _pageIndex = HomeTabValue.showcase.index;
  // int _pageIndex = HomeTabValue.interplay.index;
  int get pageIndex => _pageIndex;
  int get _tabIndex => [
        HomeShowcase.pageWrapperKey.currentState?.tabIndex,
        HomeUnderway.pageWrapperKey.currentState?.tabIndex,
        null,
        null,
      ][_pageIndex];
  String get tagPrefix => '$_pageIndex-$_tabIndex';
  bool _hasUpdate;
  bool _isLoaded;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);
    final version = Provider.of<VersionModel>(context, listen: false);
    version.init();
    // TODO: [MVP] реализовать hasUpdate
    _hasUpdate = isInDebugMode;
    _isLoaded = false;
    // analytics.setCurrentScreen(screenName: '/home');
    WidgetsBinding.instance.addPostFrameCallback(_onAfterBuild);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onAfterBuild(Duration timeStamp) {
    appState = PersistedAppState.of(context);
    assert(appState != null);
    navigator.push(StartScreen().getRoute());
    setState(() {
      _isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return Scaffold();
    }
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
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          HomeShowcase(pageIndex: 0),
          HomeUnderway(pageIndex: 1),
          HomeInterplay(pageIndex: 2),
          HomeProfile(hasUpdate: _hasUpdate),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildAddButton(),
      bottomNavigationBar: _NavigationBar(
        tabIndex: _pageIndex,
        onChangeTabIndex: _pageController.jumpToPage,
      ),
      extendBody: true,
    );
  }

  void _onPageChanged(int value) {
    setState(() {
      _pageIndex = value;
    });
  }

  Widget _buildAddButton() {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      foregroundColor: Colors.pinkAccent,
      onPressed: () async {
        final kind = await navigator.push<KindValue>(
          KindsScreen().getRoute(),
        ); // as KindValue; // workaround for typecast
        if (kind == null) return;
        // ignore: unawaited_futures
        navigator.push(
          AddUnitScreen(
            kind: kind,
            tabIndex: AddUnitTabIndex(
              showcase: HomeShowcase.pageWrapperKey.currentState?.tabIndex,
              underway: HomeUnderway.pageWrapperKey.currentState?.tabIndex,
            ),
          ).getRoute(),
        );
      },
      tooltip: 'Add Unit',
      elevation: kButtonElevation,
      child: Icon(
        Icons.add,
        size: kBigButtonIconSize * 1.2,
      ),
    );
  }
}

class _NavigationBar extends StatelessWidget {
  _NavigationBar({this.tabIndex, this.onChangeTabIndex});

  final int tabIndex;
  final void Function(int) onChangeTabIndex;
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
      shape: CircularNotchedRectangle(),
      clipBehavior: Clip.hardEdge,
      notchMargin: 8,
      color: _backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: children,
      ),
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
