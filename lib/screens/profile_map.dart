import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class ProfileMapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Map'),
      ),
      drawer: MainDrawer('/profile_map'),
      body: MapWidget(),
    );
  }
}
