import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class SearchScreen extends StatelessWidget {
  PageRoute<T> route<T>() {
    return buildRoute<T>(
      '/search',
      builder: (_) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExtendedAppBar(
        title: Text('Search'),
      ),
      drawer: MainDrawer('/search'),
      // тут не надо ScrollBody
      body: SafeArea(
        child: Center(
          child: Text('xxx'),
        ),
      ),
    );
  }
}
