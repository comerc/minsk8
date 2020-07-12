import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:minsk8/import.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _showcaseKey = GlobalKey<ShowcaseState>();
  final _underwayKey = GlobalKey<ShowcaseState>();
  int _tabIndex = 0;
  int get tabIndex => _tabIndex;
  int get _subTabIndex => [
        _showcaseKey.currentState?.tabIndex,
        _underwayKey.currentState?.tabIndex,
        null,
        null,
      ][_tabIndex];
  String get tagPrefix => '$_tabIndex-$_subTabIndex';

  @override
  void initState() {
    super.initState();
    _initDynamicLinks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: isInDebugMode ? MainDrawer(null) : null,
      appBar: PreferredSize(
        child: Container(), // TODO: Stack + Positioned для MainDrawer
        preferredSize: Size(0, 0),
      ),
      body: [
        ShowcasePage(
          showcaseKey: _showcaseKey,
        ),
        UnderwayPage(
          showcaseKey: _underwayKey,
        ),
        Chat(),
        Profile(),
      ][_tabIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: buildAddButton(
        context,
        getTabIndex: () => AddItemRouteArgumentsTabIndex(
          showcase: _showcaseKey.currentState?.tabIndex,
          underway: _underwayKey.currentState?.tabIndex,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        tabIndex: _tabIndex,
        onChangeTabIndex: _onChangeTabIndex,
      ),
      extendBody: true,
    );
  }

  void _onChangeTabIndex(int tabIndex) {
    setState(() {
      _tabIndex = tabIndex;
    });
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
