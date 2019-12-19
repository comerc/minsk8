import "package:flutter/material.dart";
import 'package:minsk8/import.dart';

class ChatRouteArguments {
  final int userId;

  ChatRouteArguments(this.userId);
}

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      drawer: MainDrawer('/chat'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}
