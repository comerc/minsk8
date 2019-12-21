import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class OldShowcaseScreen extends StatefulWidget {
  @override
  _OldShowcaseScreenState createState() => _OldShowcaseScreenState();
}

class _OldShowcaseScreenState extends State<OldShowcaseScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: kinds.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Showcase'),
          bottom: TabBar(
            isScrollable: true,
            tabs: kinds
                .map((kind) => SizedBox(
                    width: 130.0,
                    child: Tab(
                      text: kind.name,
                      icon: Icon(kind.icon),
                    )))
                .toList(),
          ),
        ),
        // drawer: MainDrawer('/showcase'),
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
