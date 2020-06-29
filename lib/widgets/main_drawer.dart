import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

final mainRoutes = [
  {
    'title': 'About',
    'routeName': '/about',
  },
  {
    'title': 'Add Item',
    'routeName': '/add_item',
    'arguments': AddItemRouteArguments(kind: KindValue.technics, tabIndex: 0),
  },
  {
    'title': 'Animation',
    'routeName': '/animation',
  },
  {
    'title': 'Custom Dialog',
    'routeName': '/custom_dialog',
    'arguments': CustomDialogScreen(),
  },
  {
    'title': 'Edit Item',
    'routeName': '/edit_item',
    'arguments': EditItemRouteArguments(0),
  },
  {
    'title': 'FAQ',
    'routeName': '/faq',
  },
  {
    'title': 'Forgot Password',
    'routeName': '/forgot_password',
  },
  {
    'title': 'Image Capture',
    'routeName': '/image_capture',
  },
  {
    'title': 'Image Pinch',
    'routeName': '/image_pinch',
    'arguments':
        ImagePinchRouteArguments('https://picsum.photos/seed/1234/600/800'),
  },
  // {
  //   'title': 'Item',
  //   'routeName': '/item',
  //   'arguments': ItemRouteArguments(profile.member.items[0]),
  // },
  {
    'title': 'Select Kind(s)',
    'routeName': '/kinds',
    'arguments': KindsRouteArguments(KindValue.pets),
  },
  {
    'title': 'Load Data',
    'routeName': '/load_data',
  },
  {
    'title': 'Login',
    'routeName': '/login',
  },
  {
    'title': 'My Items',
    'routeName': '/my_items',
  },
  {
    'title': 'Notifications',
    'routeName': '/notifications',
  },
  {
    'title': 'Pay',
    'routeName': '/pay',
  },
  {
    'title': 'Profile Map',
    'routeName': '/profile_map',
  },
  {
    'title': 'Search',
    'routeName': '/search',
  },
  {
    'title': 'Settings',
    'routeName': '/settings',
  },
  {
    'title': 'Showcase',
    'routeName': '/showcase',
  },
  {
    'title': 'Sign Up',
    'routeName': '/sign_up',
  },
  {
    'title': 'Start',
    'routeName': '/start',
  },
  {
    'title': 'Useful Tips',
    'routeName': '/useful_tips',
  },
  {
    'title': 'Wallet',
    'routeName': '/wallet',
  },
  {
    'title': 'Wishes',
    'routeName': '/wishes',
  },
];

class MainDrawer extends StatelessWidget {
  final String currentRouteName;

  MainDrawer(this.currentRouteName);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            child: GestureDetector(
              onTap: () {
                Navigator.popUntil(context, (route) => false);
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
                selected: currentRouteName == mainRoute['routeName'],
                onTap: () {
                  if (mainRoute['arguments'] == null) {
                    Navigator.pushNamed(
                      context,
                      mainRoute['routeName'],
                    );
                  }
                  Navigator.pushNamed(
                    context,
                    mainRoute['routeName'],
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
