import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen(this.arguments);

  final ChatRouteArguments arguments;

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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: buildAddButton(context),
      bottomNavigationBar: NavigationBar(currentRouteName: '/chat'),
      extendBody: true,
    );
  }
}

class ChatRouteArguments {
  ChatRouteArguments(this.userId);

  final int userId;
}
