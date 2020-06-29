import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  final _showcaseKey = GlobalKey<ShowcaseState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: isInDebugMode ? MainDrawer(null) : null,
      body: Showcase(key: _showcaseKey),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: buildAddButton(
        context,
        getTabIndex: () => _showcaseKey.currentState.tabIndex,
      ),
      bottomNavigationBar:
          NavigationBar(tabIndex: _tabIndex, onChange: _onChange),
      extendBody: true,
    );
  }

  void _onChange(int tabIndex) {
    setState(() {
      _tabIndex = tabIndex;
    });
  }
}
