import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

// TODO: не сбрасывать позицию скрола при переходах по табам bottomNavigationBar

enum HomeTabValue { showcase, underway, interplay, profile }

class HomeScreen extends StatefulWidget {
  HomeScreen() : super(key: globalKey);

  static final globalKey = GlobalKey<HomeScreenState>();

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _tabIndex = HomeTabValue.interplay.index;
  PageController _pageController;
  // int _tabIndex = HomeTabValue.showcase.index;
  int get tabIndex => _tabIndex;
  int get _subTabIndex => [
        HomeShowcase.wrapperKey.currentState?.tabIndex,
        HomeUnderway.wrapperKey.currentState?.tabIndex,
        null,
        null,
      ][_tabIndex];
  String get tagPrefix => '$_tabIndex-$_subTabIndex';
  bool _hasUpdate;
  List<Widget> _children;

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
      //     HomeShowcase(),
      //     HomeUnderway(),
      //     HomeInterplay(),
      //     HomeProfile(version: _version, hasUpdate: _hasUpdate),
      //   ],
      //   index: _tabIndex,
      // ),
      // body: <Widget>[
      //   HomeShowcase(),
      //   HomeUnderway(),
      //   HomeInterplay(),
      //   HomeProfile(version: _version, hasUpdate: _hasUpdate),
      // ][_tabIndex],
      // see here: https://developpaper.com/three-ways-to-keep-the-state-of-the-original-page-after-page-switching-by-flutter/
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _getChildren(),
        physics: NeverScrollableScrollPhysics(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildAddButton(),
      bottomNavigationBar: NavigationBar(
        tabIndex: _tabIndex,
        onChangeTabIndex: _onChangeTabIndex,
      ),
      extendBody: true,
    );
  }

  List<Widget> _getChildren() {
    _children ??= <Widget>[
      HomeShowcase(),
      HomeUnderway(),
      HomeInterplay(),
      // TODO: [MVP] не передается версия
      HomeProfile(hasUpdate: _hasUpdate),
    ];
    return _children;
  }

  void _onPageChanged(int value) {
    setState(() {
      _tabIndex = value;
    });
  }

  void _onChangeTabIndex(int tabIndex) {
    _pageController.jumpToPage(tabIndex);
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
      Navigator.pushReplacementNamed(
        context,
        '/unit',
        arguments: arguments,
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
        Navigator.pushNamed(
          context,
          '/unit',
          arguments: arguments,
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
    final client = GraphQLProvider.of(context).value;
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
        final kind = await Navigator.pushNamed(
          context,
          '/kinds',
        ) as KindValue; // workaround for typecast
        if (kind == null) return;
        // ignore: unawaited_futures
        Navigator.pushNamed(
          context,
          '/add_unit',
          arguments: AddUnitRouteArguments(
            kind: kind,
            tabIndex: AddUnitRouteArgumentsTabIndex(
              showcase: HomeShowcase.wrapperKey.currentState?.tabIndex,
              underway: HomeUnderway.wrapperKey.currentState?.tabIndex,
            ),
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
