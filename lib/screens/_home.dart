import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      drawer: MainDrawer(null),
      body: Center(child: Text('1234')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: buildAddButton(
        context,
        // getTabIndex: () => _tabController.index,
      ),
      bottomNavigationBar: NavigationBar(currentRouteName: '/showcase'),
      extendBody: true,
    );
  }
}
