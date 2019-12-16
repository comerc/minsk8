import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';
import '../const/fake_items.dart' show items;
import '../widgets/showcase_card.dart';

class ShowcaseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Showcase'),
      ),
      drawer: MainDrawer('/showcase'),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];
          return ShowcaseCard(item);
        },
      ),
    );
  }
}
