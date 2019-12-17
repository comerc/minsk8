import 'package:flutter/material.dart';

final mainRoutes = [
  {
    'title': 'Map',
    'route': '/map',
  },
  {
    'title': 'Image Capture',
    'route': '/image_capture',
  },
  {
    'title': 'Showcase',
    'route': '/showcase',
  },
  {
    'title': 'Item',
    'route': '/item',
    'arguments': {'id': 0},
  },
];

class MainDrawer extends StatelessWidget {
  final currentRoute;

  MainDrawer(this.currentRoute);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/');
              },
              child: Container(
                color: Colors.red,
                child: Center(
                  child: Text('Макет'),
                ),
              ),
            ),
          ),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: mainRoutes.length,
            itemBuilder: (BuildContext context, int index) {
              final mainRoute = mainRoutes[index];
              return ListTile(
                title: Text(mainRoute['title']),
                selected: currentRoute == mainRoute['route'],
                onTap: () {
                  if (mainRoute['arguments'] == null) {
                    Navigator.pushNamed(
                      context,
                      mainRoute['route'],
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      mainRoute['route'],
                      arguments: mainRoute['arguments'],
                    );
                  }
                },
              );
            },
          )
        ],
      ),
    );
  }
}
