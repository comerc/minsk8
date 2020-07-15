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
    return Scaffold();
  }

  void _onAfterBuild(Duration timeStamp) {
    appState['StartMap.isInitialized'] = false;
    if (appState['StartMap.isInitialized'] ?? false) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacementNamed('/start_map').then((value) {
      if (value ?? false) {
        appState['StartMap.isInitialized'] = true;
      }
    });
  }
}
