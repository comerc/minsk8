import 'dart:async';
import 'package:flutter/material.dart';
import 'package:state_persistence/state_persistence.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:minsk8/import.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    print(details);
    // if (isInDebugMode) {
    //   // In development mode, simply print to console.
    //   FlutterError.dumpErrorToConsole(details);
    // } else {
    //   // In production mode, report to the application zone to report to
    //   // Sentry.
    //   Zone.current.handleUncaughtError(details.exception, details.stack);
    // }
  };
  runZoned<Future<void>>(() async {
    runApp(App());
  }, onError: (error, stackTrace) {
    print(error);
    // Whenever an error occurs, call the `_reportError` function. This sends
    // Dart errors to the dev console or Sentry depending on the environment.
    // _reportError(error, stackTrace);
  });
}

// Future<void> _reportError(dynamic error, dynamic stackTrace) async {
//   // Print the exception to the console.
//   print('Caught error: $error');
//   if (isInDebugMode) {
//     // Print the full stacktrace in debug mode.
//     print(stackTrace);
//     return;
//   } else {
//     // Send the Exception and Stacktrace to Sentry in Production mode.
//     _sentry.captureException(
//       exception: error,
//       stackTrace: stackTrace,
//     );
//   }
// }

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PersistedAppState(
      storage: JsonFileStorage(),
      child: GraphQLProvider(
        client: ValueNotifier(
          GraphQLClient(
            cache: InMemoryCache(),
            link: HttpLink(uri: kGraphQLEndpoint, headers: {
              'X-Hasura-Role': 'user',
              'X-Hasura-User-Id': memberId, // TODO: переместить в JWT
            }),
          ),
        ),
        child: CacheProvider(
          child: MaterialApp(
            // debugShowCheckedModeBanner: false,
            title: 'minsk8',
            // theme: ThemeData(
            //   primarySwatch: mapBoxBlue,
            // ),
            builder: (BuildContext context, Widget child) {
              //If the design is based on the size of the iPhone6 ​​(iPhone6 ​​750*1334)
              //If you want to set the font size is scaled according to the system's "font size" assist option
              // ScreenUtil.instance =
              //     ScreenUtil(width: 300, height: 700, allowFontScaling: true)
              //       ..init(context);
              final data = MediaQuery.of(context);
              return MediaQuery(
                data: data.copyWith(textScaleFactor: 1.0),
                child: PersistedStateBuilder(
                  builder: (BuildContext context,
                      AsyncSnapshot<PersistedData> snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        color: Colors.white,
                        // alignment: Alignment.center,
                        // child: CircularProgressIndicator(),
                      );
                    }
                    return child;
                  },
                ),
              );
            },
            initialRoute: '/showcase',
            // home: NestedScrollViewDemo(),
            routes: <String, WidgetBuilder>{
              '/about': (context) => AboutScreen(),
              '/add_item': (context) => AddItemScreen(),
              '/chat': (context) => ChatScreen(),
              '/edit_item': (context) => EditItemScreen(),
              '/forgot_password': (context) => ForgotPasswordScreen(),
              '/home': (context) => HomeScreen(),
              '/image_capture': (context) => ImageCaptureScreen(),
              '/image_pinch': (context) => ImagePinchScreen(),
              '/item': (context) => ItemScreen(),
              '/kinds': (context) => KindsScreen(),
              '/login': (context) => LoginScreen(),
              '/map': (context) => MapScreen(),
              '/my_items': (context) => MyItemsScreen(),
              '/notifications': (context) => NotificationsScreen(),
              '/pay': (context) => PayScreen(),
              '/profile': (context) => ProfileScreen(),
              '/search': (context) => SearchScreen(),
              '/settings': (context) => SettingsScreen(),
              '/showcase': (context) => ShowcaseScreen(),
              '/sign_up': (context) => SignUpScreen(),
              '/start': (context) => StartScreen(),
              '/underway': (context) => UnderwayScreen(),
              '/wallet': (context) => WalletScreen(),
              '/wishes': (context) => WishesScreen(),
            },
            // onGenerateRoute: (settings) {
            //   print('onGenerateRoute: $settings');
            //   return null;
            // },
            // onUnknownRoute: (RouteSettings settings) => MaterialPageRoute<Null>(
            //   settings: settings,
            //   builder: (BuildContext context) => UnknownPage(settings.name),
            // ),
          ),
        ),
      ),
    );
  }
}

// Generated using Material Design Palette/Theme Generator
// http://mcg.mbitson.com/
// https://github.com/mbitson/mcg
// const int _bluePrimary = 0xFF395afa;
// const MaterialColor mapBoxBlue = MaterialColor(
//   _bluePrimary,
//   <int, Color>{
//     50: Color(0xFFE7EBFE),
//     100: Color(0xFFC4CEFE),
//     200: Color(0xFF9CADFD),
//     300: Color(0xFF748CFC),
//     400: Color(0xFF5773FB),
//     500: Color(_bluePrimary),
//     600: Color(0xFF3352F9),
//     700: Color(0xFF2C48F9),
//     800: Color(0xFF243FF8),
//     900: Color(0xFF172EF6),
//   },
// );
