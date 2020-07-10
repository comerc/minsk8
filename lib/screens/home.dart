import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:minsk8/import.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navigationBartabIndex = 0;
  // int _showcaseTabIndex = 0;
  final _showcaseKey = GlobalKey<CommonShowcaseState>();

  @override
  void initState() {
    super.initState();
    _initDynamicLinks();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: isInDebugMode ? MainDrawer(null) : null,
      body: IndexedStack(
        children: [
          Showcase(
            showcaseKey: _showcaseKey,
            // tabIndex: _showcaseTabIndex,
            // onChangeTabIndex: _onChangeShowcaseTabIndex,
          ),
          Underway(),
          Chat(),
          Profile(),
        ],
        index: _navigationBartabIndex,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: buildAddButton(
        context,
        getTabIndex: () => _showcaseKey.currentState.tabIndex,
      ),
      bottomNavigationBar: NavigationBar(
        tabIndex: _navigationBartabIndex,
        onChangeTabIndex: _onChangeNavigationBarTabIndex,
      ),
      extendBody: true,
    );
  }

  void _onChangeNavigationBarTabIndex(int tabIndex) {
    setState(() {
      _navigationBartabIndex = tabIndex;
    });
  }

  // void _onChangeShowcaseTabIndex(int tabIndex) {
  //   _showcaseTabIndex = tabIndex;
  // }

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
