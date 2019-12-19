import "package:flutter/material.dart";
import 'package:minsk8/import.dart';

class WishListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wish List'),
      ),
      drawer: MainDrawer('/wish_list'),
      body: Center(
        child: Text('xxx'),
      ),
    );
  }
}
