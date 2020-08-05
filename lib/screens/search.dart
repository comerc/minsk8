import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      drawer: MainDrawer('/search'),
      // тут не надо ScrollBody
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}
