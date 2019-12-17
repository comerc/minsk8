import "package:flutter/material.dart";
import '../widgets/main_drawer.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      drawer: MainDrawer('/search'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}
