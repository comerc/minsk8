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
  {
    'title': 'Wish List',
    'route': '/wish_list',
  },
  {
    'title': 'Underway',
    'route': '/underway',
  },
  {
    'title': 'Search',
    'route': '/search',
  },
  {
    'title': 'Login',
    'route': '/login',
  },
  {
    'title': 'Sign Up',
    'route': '/sign_up',
  },
  {
    'title': 'Forgot Password',
    'route': '/forgot-password',
  },
  {
    'title': 'Profile',
    'route': '/profile',
  },
  {
    'title': 'Chat',
    'route': '/chat',
    'arguments': {'user_id': 0},
  },
  {
    'title': 'Select Kind(s)',
    'route': '/kinds',
  },
  {
    'title': 'Add Item',
    'route': '/add_item',
  },
  {
    'title': 'Edit Item',
    'route': '/edit_item',
    'arguments': {'id': 0},
  },
  {
    'title': 'My Items',
    'route': '/my_items',
  },
  {
    'title': 'Notifications',
    'route': '/notifications',
  }
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
                  }
                  Navigator.pushNamed(
                    context,
                    mainRoute['route'],
                    arguments: mainRoute['arguments'],
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }
}
