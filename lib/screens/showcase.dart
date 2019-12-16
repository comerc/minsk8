import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';
import '../const/fake_items.dart' show items;
import '../widgets/showcase_card.dart';

class ShowcaseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Showcase'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.directions_car)),
              Tab(icon: Icon(Icons.directions_transit)),
              Tab(icon: Icon(Icons.directions_bike)),
            ],
          ),
        ),
        drawer: MainDrawer('/showcase'),
        body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return ShowcaseCard(index);
          },
        ),
      ),
    );
  }
}
