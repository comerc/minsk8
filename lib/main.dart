// import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:state_persistence/state_persistence.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
// import 'package:extended_image/extended_image.dart';
import 'package:minsk8/import.dart';

// TODO: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_analytics
// TODO: на всех экранах, где не нужна клавиатура, вставить Scaffold.resizeToAvoidBottomInset: false,
// TODO: поменять все print(object) на debugPrint(String) ?

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
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    runApp(App());
  }, (error, stackTrace) {
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

// TODO: Обернуть требуемые экраны в SafeArea (проверить на iPhone X)

PersistedData appState;
List<ItemsRepository> sourceListPool;
final localDeletedItemIds = Set<String>();

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // print('App build');
    Widget result = MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'minsk8',
      // theme: ThemeData(
      //   primarySwatch: mapBoxBlue,
      //   visualDensity: VisualDensity.adaptivePlatformDensity
      // ),
      builder: (BuildContext context, Widget child) {
        sourceListPool = allKinds
            .map((kind) => ItemsRepository(context, kind.value))
            .toList();
        return PersistedStateBuilder(
          builder:
              (BuildContext context, AsyncSnapshot<PersistedData> snapshot) {
            if (!snapshot.hasData) {
              return Material(
                child: Container(
                  alignment: Alignment.center,
                  child: Text('Loading state...'),
                ),
              );
            }
            appState = PersistedAppState.of(context);
            return Query(
              options: QueryOptions(
                documentNode: Queries.getProfile,
                variables: {'member_id': memberId},
                fetchPolicy: FetchPolicy.noCache,
              ),
              // Just like in apollo refetch() could be used to manually trigger a refetch
              // while fetchMore() can be used for pagination purpose
              builder: (QueryResult result,
                  {VoidCallback refetch, FetchMore fetchMore}) {
                if (result.hasException) {
                  return Material(
                    child: InkWell(
                      onTap: refetch,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                            getOperationExceptionToString(result.exception)),
                      ),
                    ),
                  );
                }
                if (result.loading) {
                  return Material(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text('Loading profile...'),
                    ),
                  );
                }
                return MultiProvider(
                  providers: [
                    ChangeNotifierProvider<ProfileModel>(
                        create: (_) =>
                            ProfileModel.fromJson(result.data['profile'])),
                    ChangeNotifierProvider<DistanceModel>(
                        create: (_) => DistanceModel()),
                    ChangeNotifierProvider<ItemMapModel>(
                        create: (_) => ItemMapModel()),
                  ],
                  child: MediaQueryWrap(child),
                );
              },
            );
          },
        );
        // );
      },
      initialRoute: '/showcase',
      // home: NestedScrollViewDemo(),
      routes: <String, WidgetBuilder>{
        '/about': (_) => MarkdownScreen('about.md', title: 'О проекте'),
        '/add_item': (BuildContext context) =>
            AddItemScreen(ModalRoute.of(context).settings.arguments),
        '/animation': (_) => AnimationScreen(),
        '/chat': (BuildContext context) =>
            ChatScreen(ModalRoute.of(context).settings.arguments),
        '/custom_dialog': (_) => CustomDialogScreen(),
        '/edit_item': (BuildContext context) =>
            EditItemScreen(ModalRoute.of(context).settings.arguments),
        '/faq': (_) => MarkdownScreen('faq.md', title: 'FAQ'),
        '/forgot_password': (_) => ForgotPasswordScreen(),
        '/home': (_) => HomeScreen(),
        '/image_capture': (_) => ImageCaptureScreen(),
        '/image_pinch': (_) => ImagePinchScreen(),
        '/zoom': (BuildContext context) =>
            ZoomScreen(ModalRoute.of(context).settings.arguments),
        '/item_map': (BuildContext context) =>
            ItemMapScreen(ModalRoute.of(context).settings.arguments),
        '/item': (BuildContext context) =>
            ItemScreen(ModalRoute.of(context).settings.arguments),
        '/kinds': (BuildContext context) =>
            KindsScreen(ModalRoute.of(context).settings.arguments),
        '/login': (_) => LoginScreen(),
        '/my_item_map': (_) => MyItemMapScreen(),
        '/my_items': (_) => MyItemsScreen(),
        '/notifications': (_) => NotificationsScreen(),
        '/pay': (_) => PayScreen(),
        '/profile_map': (_) => ProfileMapScreen(),
        '/profile': (_) => ProfileScreen(),
        '/search': (_) => SearchScreen(),
        '/settings': (_) => SettingsScreen(),
        '/showcase': (_) => ShowcaseScreen(),
        '/sign_up': (_) => SignUpScreen(),
        '/start': (_) => StartScreen(),
        '/underway': (_) => UnderwayScreen(),
        '/useful_tips': (_) =>
            MarkdownScreen('useful_tips.md', title: 'Полезные советы'),
        '/wallet': (_) => WalletScreen(),
        '/wishes': (_) => WishesScreen(),
      },
      // onGenerateRoute: (RouteSettings settings) {
      //   // if (settings.name == '/item') {
      //   //   return Platform.isIOS
      //   //       ? TransparentCupertinoPageRoute(
      //   //           settings: settings,
      //   //           builder: (BuildContext context) => ItemScreen())
      //   //       : TransparentMaterialPageRoute(
      //   //           settings: settings,
      //   //           builder: (BuildContext context) => ItemScreen());
      //   // }
      //   print('onGenerateRoute: $settings');
      //   return null;
      // },
      // onUnknownRoute: (RouteSettings settings) => MaterialPageRoute<Null>(
      //   settings: settings,
      //   builder: (BuildContext context) => UnknownPage(settings.name),
      // ),
    );
    result = GraphQLProvider(
      client: ValueNotifier(
        GraphQLClient(
          cache: InMemoryCache(),
          // cache: NormalizedInMemoryCache(
          //   dataIdFromObject: typenameDataIdFromObject,
          // ),
          link: HttpLink(uri: kGraphQLEndpoint, headers: {
            'X-Hasura-Role': 'user',
            'X-Hasura-User-Id': memberId, // TODO: переместить в JWT
          }),
        ),
      ),
      child: CacheProvider(
        child: result,
      ),
    );
    result = PersistedAppState(
      storage: JsonFileStorage(),
      child: result,
    );
    result = LifeCycleManager(
      onInitState: () {},
      onDispose: () {
        sourceListPool?.forEach((sourceList) {
          sourceList.dispose();
        });
        sourceListPool = null;
      },
      child: result,
    );
    return result;
  }
}

// Widget need for reactive variable
class MediaQueryWrap extends StatelessWidget {
  MediaQueryWrap(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    //If the design is based on the size of the iPhone6 ​​(iPhone6 ​​750*1334)
    //If you want to set the font size is scaled according to the system's "font size" assist option
    // ScreenUtil.instance =
    //     ScreenUtil(width: 300, height: 700, allowFontScaling: true)
    //       ..init(context);
    final data = MediaQuery.of(context);
    return MediaQuery(
      data: data.copyWith(textScaleFactor: 1),
      child: child,
    );
  }
}

// String typenameDataIdFromObject(Object object) {
//   if (object is Map<String, Object> && object.containsKey('__typename')) {
//     if (object['__typename'] == 'profile') {
//       final member = object['member'] as Map<String, Object>;
//       print('profile/${member['id']}');
//       return 'profile/${member['id']}';
//     }
//   }
//   return null;
// }

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
