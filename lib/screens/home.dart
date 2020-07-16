import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:minsk8/import.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen() : super(key: globalKey);

  static final globalKey = GlobalKey<HomeScreenState>();

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  int get tabIndex => _tabIndex;
  int get _subTabIndex => [
        ShowcasePage.showcaseKey.currentState?.tabIndex,
        UnderwayPage.showcaseKey.currentState?.tabIndex,
        null,
        null,
      ][_tabIndex];
  String get tagPrefix => '$_tabIndex-$_subTabIndex';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: isInDebugMode ? MainDrawer(null) : null,
      appBar: PreferredSize(
        child: Container(), // TODO: Stack + Positioned для MainDrawer
        preferredSize: Size.zero, // hack
      ),
      body: [
        ShowcasePage(),
        UnderwayPage(),
        ChatPage(),
        ProfilePage(),
      ][_tabIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: buildAddButton(
        context,
        getTabIndex: () => AddItemRouteArgumentsTabIndex(
          showcase: ShowcasePage.showcaseKey.currentState?.tabIndex,
          underway: UnderwayPage.showcaseKey.currentState?.tabIndex,
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

  Future<void> initDynamicLinks() async {
    final data = await FirebaseDynamicLinks.instance.getInitialLink();
    // for StartScreen
    _openDeepLink(data?.link).then((ItemRouteArguments arguments) {
      if (arguments == null) {
        Navigator.of(context).pop();
        return;
      }
      Navigator.pushReplacementNamed(
        context,
        '/item',
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
        Navigator.pushNamed(
          context,
          '/item',
          arguments: arguments,
        );
      },
      onError: (OnLinkErrorException error) async {
        debugPrint(error.message);
      },
    );
  }

  Future<ItemRouteArguments> _openDeepLink(Uri link) async {
    if (link == null || link.path != '/item') return null;
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
    return ItemRouteArguments(
      item,
      member: item.member,
    );
  }
}
