import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

final mainRoutes = [
  {
    'title': 'Animation',
    'routeName': '/_animation',
  },
  {
    'title': 'Custom Dialog',
    'routeName': '/_custom_dialog',
    'arguments': CustomDialogScreen(),
  },
  {
    'title': 'Image Capture',
    'routeName': '/_image_capture',
  },
  {
    'title': 'Image Pinch',
    'routeName': '/_image_pinch',
    'arguments':
        ImagePinchRouteArguments('https://picsum.photos/seed/1234/600/800'),
  },
  {
    'title': 'Load Data',
    'routeName': '/_load_data',
  },
  {
    'title': 'Notification',
    'routeName': '/_notification',
  },
  // ****
  {
    'title': 'About',
    'routeName': '/about',
  },
  {
    'title': 'Add Item',
    'routeName': '/add_item',
    'arguments': AddItemRouteArguments(kind: KindValue.technics),
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
    'title': 'Item',
    'routeName': '/item',
    // ignore: top_level_function_literal_block
    'arguments': (BuildContext context) async {
      final profile = Provider.of<ProfileModel>(context, listen: false);
      final options = QueryOptions(
        documentNode: Queries.getItem,
        variables: {'id': profile.member.items[0].id},
        fetchPolicy: FetchPolicy.noCache,
      );
      final client = GraphQLProvider.of(context).value;
      final result = await client
          .query(options)
          .timeout(Duration(seconds: kGraphQLQueryTimeout));
      if (result.hasException) {
        throw result.exception;
      }
      final item = ItemModel.fromJson(result.data['item']);
      return ItemRouteArguments(
        item,
        member: item.member,
      );
    },
  },
  {
    'title': 'Select Kind(s)',
    'routeName': '/kinds',
    'arguments': KindsRouteArguments(KindValue.pets),
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
                Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                );
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
                onTap: () async {
                  Navigator.of(context).popUntil(
                      (route) => route.settings.name == kInitialRouteName);
                  final arguments = (mainRoute['arguments'] is Function)
                      ? await (mainRoute['arguments'] as Function)(context)
                      : mainRoute['arguments'];
                  if (arguments == null) {
                    Navigator.of(context).pushNamed(
                      mainRoute['routeName'],
                    );
                    return;
                  }
                  Navigator.of(context).pushNamed(
                    mainRoute['routeName'],
                    arguments: arguments,
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
