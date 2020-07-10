import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification'),
      ),
      drawer: MainDrawer('/_notification'),
      body: Center(child: Text('notification')),
    );
  }
}
