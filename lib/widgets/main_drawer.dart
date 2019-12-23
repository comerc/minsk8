import 'package:minsk8/import.dart';

final mainRoutes = [
  {
    'title': 'About',
    'routeName': '/about',
  },
  {
    'title': 'Add Item',
    'routeName': '/add_item',
  },
  {
    'title': 'Chat',
    'routeName': '/chat',
    'arguments': ChatRouteArguments(0),
  },
  {
    'title': 'Edit Item',
    'routeName': '/edit_item',
    'arguments': {'id': 0},
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
    'title': 'Item',
    'routeName': '/item',
    'arguments': ItemRouteArguments(0),
  },
  {
    'title': 'Select Kind(s)',
    'routeName': '/kinds',
  },
  {
    'title': 'Login',
    'routeName': '/login',
  },
  {
    'title': 'Map',
    'routeName': '/map',
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
    'title': 'Profile',
    'routeName': '/profile',
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
    'title': 'Underway',
    'routeName': '/underway',
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
