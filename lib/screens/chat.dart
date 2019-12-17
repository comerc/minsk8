import "package:flutter/material.dart";
import '../widgets/main_drawer.dart';

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
