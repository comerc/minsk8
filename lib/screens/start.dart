import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class StartScreen extends StatefulWidget {
  @override
  StartScreenState createState() {
    return StartScreenState();
  }
}

class StartScreenState extends State<StartScreen> {
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
    if (appState['StartMap.isInitialized'] ?? false) {
      return;
    }
    // TODO: WelcomeScreen
    final value = await Navigator.of(context).pushNamed('/start_map');
    if (value ?? false) {
      appState['StartMap.isInitialized'] = true;
    }
  }

  void _onAfterBuild(Duration timeStamp) async {
    await initStartMap();
    HomeScreen.globalKey.currentState.initDynamicLinks();
  }
}
