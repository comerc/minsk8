import 'package:flutter/material.dart';

final mainRoutes = [
  {
    'route': '/map',
    'title': 'Map',
  },
  {
    'route': '/image_capture',
    'title': 'Image Capture',
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
                Navigator.pushReplacementNamed(context, '/');
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
                  Navigator.pushNamed(context, mainRoute['route']);
                },
              );
            },
          )
        ],
      ),
    );
  }
}
