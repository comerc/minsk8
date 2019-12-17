import "package:flutter/material.dart";
import '../widgets/main_drawer.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      drawer: MainDrawer('/notifications'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}
