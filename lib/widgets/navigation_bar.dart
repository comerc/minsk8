import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class NavigationBar extends StatelessWidget {
  final String currentRouteName;
  final double height = kNavigationBarHeight;
  final Color backgroundColor = Colors.white;
  final Color color = Colors.grey;
  final Color selectedColor = Colors.pinkAccent;

  NavigationBar({this.currentRouteName});

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
          children: [
            SizedBox(height: kBigButtonIconSize),
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
                children: [
                  Icon(
                    tab.icon,
                    color: color,
                    size: kBigButtonIconSize,
                  ),
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
