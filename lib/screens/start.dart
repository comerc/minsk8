import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:graphql/client.dart';
import 'package:minsk8/import.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() {
    return _StartScreenState();
  }
}

class _StartScreenState extends State<StartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_onAfterBuild);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Старт...')));
  }

  void _onAfterBuild(Duration timeStamp) async {
    // final options = QueryOptions(
    //   document: addFragments(Queries.getChats),
    //   fetchPolicy: FetchPolicy.noCache,
    // );
    // final result =
    //     await client.query(options).timeout(kGraphQLQueryTimeoutDuration);
    // if (result.hasException) {
    //   throw result.exception;
    // }
    // final item =
    //     ChatModel.fromJson(result.data['chats'][0] as Map<String, dynamic>);
    // // ignore: unawaited_futures
    // navigator.push(
    //   MessagesScreen(
    //     chat: item,
    //   ).getRoute(),
    // );

    await _initStartMap();
    await _initDynamicLinks();
  }

  Future<void> _initStartMap() async {
    // appState['StartMap.isInitialized'] = false;
    if (appState['StartMap.isInitialized'] as bool ?? false) {
      return;
    }
    // TODO: WelcomeScreen
    final value = await navigator.push<bool>(
      StartMapScreen().getRoute(),
    );
    if (value ?? false) {
      appState['StartMap.isInitialized'] = true;
    }
  }

  Future<void> _initDynamicLinks() async {
    final data = await FirebaseDynamicLinks.instance.getInitialLink();
    await _openDeepLink(data?.link).then((UnitModel unit) {
      if (unit == null) {
        navigator.pop();
        return;
      }
      navigator.pushReplacement(
        UnitScreen(
          unit,
          member: unit.member,
          isShowcase: true,
        ).getRoute(),
      );
    }).catchError((error) {
      out(error);
      navigator.pop();
    });
    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData data) async {
        final unit = await _openDeepLink(data?.link);
        if (unit == null) {
          return;
        }
        // ignore: unawaited_futures
        navigator.push(
          UnitScreen(
            unit,
            member: unit.member,
            isShowcase: true,
          ).getRoute(),
        );
      },
      onError: (OnLinkErrorException error) async {
        out(error.message);
      },
    );
  }

  static Future<UnitModel> _openDeepLink(Uri link) async {
    if (link == null || link.path != '/unit') return null;
    final id = link.queryParameters['id'];
    final options = QueryOptions(
      document: addFragments(Queries.getUnit),
      variables: {'id': id},
      fetchPolicy: FetchPolicy.noCache,
    );
    try {
      final result =
          await client.query(options).timeout(kGraphQLQueryTimeoutDuration);
      if (result.hasException) {
        throw result.exception;
      }
      return UnitModel.fromJson(result.data['unit'] as Map<String, dynamic>);
    } catch (error, stack) {
      out(error);
      out(stack);
    }
    return null;
  }
}
