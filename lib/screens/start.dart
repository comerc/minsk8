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
  Widget build(context) {
    return Scaffold(body: Center(child: Text('Старт...')));
  }

  Future<void> initStartMap() async {
    if (appState['StartMap.isInitialized'] as bool ?? false) {
      return;
    }
    // TODO: WelcomeScreen
    final value = await navigator.push<bool>(
      StartMapScreen().route(),
    );
    if (value ?? false) {
      appState['StartMap.isInitialized'] = true;
    }
  }

  void _onAfterBuild(Duration timeStamp) async {
    // final options = QueryOptions(
    //   documentNode: Queries.getChats,
    //   fetchPolicy: FetchPolicy.noCache,
    // );
    // final client = GraphQLProvider.of(context).value;
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
    //   ).route(),
    // );

    await initStartMap();
    // TODO: почему бы это не делать внутри HomeScreen.initState ?
    // ignore: unawaited_futures
    HomeScreen.globalKey.currentState.initDynamicLinks();
  }
}
