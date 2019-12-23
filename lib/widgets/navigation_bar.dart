import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class NavigationBar extends StatelessWidget {
  final String currentRouteName;
  final double height = kNavigationBarHeight;
  final double iconSize = 32;
  final Color backgroundColor = Colors.pink;
  final Color color = Colors.black54;
  final Color selectedColor = Colors.white;

  NavigationBar(this.currentRouteName);

  @override
  Widget build(BuildContext context) {
    List<Widget> items = tabs
        .map(
          (tab) => _buildTabItem(
            context: context,
            tab: tab,
            isSelected: currentRouteName == tab.routeName,
          ),
        )
        .toList();
    items.insert(items.length >> 1, _buildMiddleTabItem());
    return BottomAppBar(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items,
      ),
      shape: CircularNotchedRectangle(),
      clipBehavior: Clip.hardEdge,
      notchMargin: 8.0,
      color: this.backgroundColor,
    );
  }

  Widget _buildMiddleTabItem() {
    return Expanded(
      child: SizedBox(
        height: this.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: this.iconSize),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    BuildContext context,
    _NavigationBarTab tab,
    bool isSelected,
  }) {
    Color color = isSelected ? this.selectedColor : this.color;
    return Expanded(
      child: SizedBox(
        height: this.height,
        child: Tooltip(
          message: tab.title,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  tab.routeName,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(tab.icon, color: color, size: this.iconSize),
                  // Text(
                  //   tab.title,
                  //   style: TextStyle(color: color),
                  // )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationBarTab {
  String title;
  IconData icon;
  String routeName;

  _NavigationBarTab({this.title, this.icon, this.routeName});
}

final tabs = [
  _NavigationBarTab(
    title: 'Showcase',
    icon: Icons.widgets,
    routeName: '/showcase',
  ),
  _NavigationBarTab(
    title: 'Underway',
    icon: Icons.queue,
    routeName: '/underway',
  ),
  _NavigationBarTab(
    title: 'Chat',
    icon: Icons.chat,
    routeName: '/chat',
  ),
  _NavigationBarTab(
    title: 'Profile',
    icon: Icons.account_box,
    routeName: '/profile',
  ),
];
