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
    'title': 'Add Unit',
    'routeName': '/add_unit',
    'arguments': AddUnitRouteArguments(kind: KindValue.technics),
  },
  {
    'title': 'Edit Unit',
    'routeName': '/edit_unit',
    'arguments': EditUnitRouteArguments(0),
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
    'title': 'Unit',
    'routeName': '/unit',
    // ignore: top_level_function_literal_block
    'arguments': (BuildContext context) async {
      final profile = Provider.of<ProfileModel>(context, listen: false);
      final options = QueryOptions(
        documentNode: Queries.getUnit,
        variables: {'id': profile.member.units[0].id},
        fetchPolicy: FetchPolicy.noCache,
      );
      final client = GraphQLProvider.of(context).value;
      final result =
          await client.query(options).timeout(kGraphQLQueryTimeoutDuration);
      if (result.hasException) {
        throw result.exception;
      }
      final unit =
          UnitModel.fromJson(result.data['unit'] as Map<String, dynamic>);
      return UnitRouteArguments(
        unit,
        member: unit.member,
      );
    },
  },
  {
    'title': 'Select Kind(s)',
    'routeName': '/kinds',
    'arguments': KindsRouteArguments(KindValue.pets),
  },
  {
    'title': 'Ledger',
    'routeName': '/ledger',
  },
  {
    'title': 'Login',
    'routeName': '/login',
  },
  {
    'title': 'My Units',
    'routeName': '/my_units',
  },
  {
    'title': 'Pay',
    'routeName': '/pay',
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
    'title': 'Showcase Map',
    'routeName': '/showcase_map',
  },
  {
    'title': 'Sign Up',
    'routeName': '/sign_up',
  },
  {
    'title': 'Start Map',
    'routeName': '/start_map',
  },
  {
    'title': 'Useful Tips',
    'routeName': '/useful_tips',
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
        children: <Widget>[
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
                title: Text(mainRoute['title'] as String),
                selected: currentRouteName == mainRoute['routeName'],
                onTap: () async {
                  Navigator.of(context).popUntil(
                      (route) => route.settings.name == kInitialRouteName);
                  final arguments = (mainRoute['arguments'] is Function)
                      ? await (mainRoute['arguments'] as Function)(context)
                      : mainRoute['arguments'];
                  if (arguments == null) {
                    // ignore: unawaited_futures
                    Navigator.of(context).pushNamed(
                      mainRoute['routeName'] as String,
                    );
                    return;
                  }
                  // ignore: unawaited_futures
                  Navigator.of(context).pushNamed(
                    mainRoute['routeName'] as String,
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
