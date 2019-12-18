import 'package:flutter/material.dart';
import 'package:state_persistence/state_persistence.dart';
import '../widgets/main_drawer.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PersistedStateBuilder(
      builder: (BuildContext context, AsyncSnapshot<PersistedData> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            alignment: Alignment.center,
            color: Colors.white,
            child: CircularProgressIndicator(),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Home'),
          ),
          drawer: MainDrawer('/'),
          body: Center(
            child: Text('Hello world!'),
          ),
        );
      },
    );
  }
}
