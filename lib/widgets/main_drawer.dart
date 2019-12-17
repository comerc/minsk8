import 'package:flutter/material.dart';

final mainRoutes = [
  {
    'title': 'About',
    'route': '/about',
  },
  {
    'title': 'Add Item',
    'route': '/add_item',
  },
  {
    'title': 'Chat',
    'route': '/chat',
    'arguments': {'user_id': 0},
  },
  {
    'title': 'Edit Item',
    'route': '/edit_item',
    'arguments': {'id': 0},
  },
  {
    'title': 'Forgot Password',
    'route': '/forgot_password',
  },
  {
    'title': 'Image Capture',
    'route': '/image_capture',
  },
  {
    'title': 'Item',
    'route': '/item',
    'arguments': {'id': 0},
  },
  {
    'title': 'Select Kind(s)',
    'route': '/kinds',
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
    'title': 'Map',
    'route': '/map',
  },
  {
    'title': 'My Items',
    'route': '/my_items',
  },
  {
    'title': 'Notifications',
    'route': '/notifications',
  },
  {
    'title': 'Pay',
    'route': '/pay',
  },
  {
    'title': 'Profile',
    'route': '/profile',
  },
  {
    'title': 'Settings',
    'route': '/settings',
  },
  {
    'title': 'Showcase',
    'route': '/showcase',
  },
  {
    'title': 'Sign Up',
    'route': '/sign_up',
  },
  {
    'title': 'Start',
    'route': '/start',
  },
  {
    'title': 'Underway',
    'route': '/underway',
  },
  {
    'title': 'Wish List',
    'route': '/wish_list',
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
                Navigator.pushNamed(context, '/home');
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
