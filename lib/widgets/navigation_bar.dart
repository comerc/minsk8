import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

typedef NavigationBarOnChangeTabIndex = void Function(int tabIndex);

class NavigationBar extends StatelessWidget {
  NavigationBar({this.tabIndex, this.onChangeTabIndex});

  final int tabIndex;
  final NavigationBarOnChangeTabIndex onChangeTabIndex;
  final double _height = kNavigationBarHeight;
  final Color _backgroundColor = Colors.white;
  final Color _color = Colors.grey;
  final Color _selectedColor = Colors.pinkAccent;
  final _tabs = [
    _NavigationBarTab(
      title: 'Showcase',
      icon: Icons.home,
      value: _NavigationBarTabValue.showcase,
    ),
    _NavigationBarTab(
      title: 'Underway',
      icon: Icons.widgets, // Icons.queue,
      value: _NavigationBarTabValue.underway,
    ),
    _NavigationBarTab(
      title: 'Chat',
      icon: Icons.chat,
      value: _NavigationBarTabValue.chat,
    ),
    _NavigationBarTab(
      title: 'Profile',
      icon: Icons.account_box,
      value: _NavigationBarTabValue.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final children = List.generate(
      _tabs.length,
      (index) => _buildTabUnit(
        context: context,
        index: index,
        isSelected: index == tabIndex,
      ),
    );
    children.insert(children.length >> 1, _buildMiddleTabUnit());
    return BottomAppBar(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: children,
      ),
      shape: CircularNotchedRectangle(),
      clipBehavior: Clip.hardEdge,
      notchMargin: 8,
      color: _backgroundColor,
    );
  }

  Widget _buildMiddleTabUnit() {
    return Expanded(
      child: SizedBox(
        height: _height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: kBigButtonIconSize),
          ],
        ),
      ),
    );
  }

  Widget _buildTabUnit({
    BuildContext context,
    int index,
    bool isSelected,
  }) {
    final tab = _tabs[index];
    final color = isSelected ? _selectedColor : _color;
    return Expanded(
      child: SizedBox(
        height: _height,
        child: Tooltip(
          message: tab.title,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () {
                onChangeTabIndex(index);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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

enum _NavigationBarTabValue { showcase, underway, chat, profile }

class _NavigationBarTab {
  _NavigationBarTab({this.title, this.icon, this.value});

  String title;
  IconData icon;
  _NavigationBarTabValue value;
}
