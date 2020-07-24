import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:state_persistence/state_persistence.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:rxdart/subjects.dart';
import 'package:minsk8/import.dart';

// TODO: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_analytics
// TODO: на всех экранах, где не нужна клавиатура, вставить Scaffold.resizeToAvoidBottomInset: false,
// TODO: поменять все print(object) на debugPrint(String) ?
// TODO: timeout для подписок GraphQL, смотри примеры

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotificationModel>();
final selectNotificationSubject = BehaviorSubject<String>();
NotificationAppLaunchDetails notificationAppLaunchDetails;

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
    notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
    // of the `IOSFlutterLocalNotificationsPlugin` class
    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotificationModel(
              id: id, title: title, body: body, payload: payload));
        });
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
      selectNotificationSubject.add(payload);
    });
    // TODO: locale autodetect
    await initializeDateFormatting('ru_RU', null);
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

// TODO: переименовать в appData
PersistedData appState;
final localDeletedUnitIds = <String>{}; // ie Set()

class App extends StatelessWidget {
  static final analytics = FirebaseAnalytics();
  static final observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    // print('App build');
    Widget result = MaterialApp(
      debugShowCheckedModeBanner: isInDebugMode,
      navigatorObservers: [observer],
      title: 'minsk8',
      // theme: ThemeData(
      //   //   primarySwatch: mapBoxBlue,
      //   //   visualDensity: VisualDensity.adaptivePlatformDensity
      //   appBarTheme: AppBarTheme(brightness: Brightness.light),
      // ),
      builder: (BuildContext context, Widget child) {
        final client = GraphQLProvider.of(context).value;
        HomeShowcase.dataPool =
            allKinds.map((kind) => ShowcaseData(client, kind.value)).toList();
        HomeUnderway.dataPool = UnderwayValue.values
            .map((value) => UnderwayData(client, value))
            .toList();
        LedgerScreen.sourceList = LedgerData(client);
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
                  debugPrint(getOperationExceptionToString(result.exception));
                  return Material(
                    child: InkWell(
                      onTap: refetch,
                      child: Center(
                        child: Text('Кажется, что-то пошло не так?'),
                      ),
                    ),
                  );
                }
                if (result.loading) {
                  return Material(
                    child: Center(
                      child: Text('Loading profile...'),
                    ),
                  );
                }
                return MultiProvider(
                  providers: [
                    ChangeNotifierProvider<ProfileModel>(
                        create: (_) =>
                            ProfileModel.fromJson(result.data['profile'])),
                    ChangeNotifierProvider<MyWishesModel>(
                        create: (_) => MyWishesModel.fromJson(result.data)),
                    ChangeNotifierProvider<DistanceModel>(
                        create: (_) => DistanceModel()),
                    ChangeNotifierProvider<MyUnitMapModel>(
                        create: (_) => MyUnitMapModel()),
                  ],
                  child: MediaQueryWrap(child),
                );
              },
            );
          },
        );
      },
      home: HomeScreen(),
      initialRoute: kInitialRouteName,
      routes: <String, WidgetBuilder>{
        '/_animation': (_) => AnimationScreen(),
        '/_custom_dialog': (_) => CustomDialogScreen(),
        '/_image_capture': (_) => ImageCaptureScreen(),
        '/_image_pinch': (_) => ImagePinchScreen(),
        '/_load_data': (_) => LoadDataScreen(),
        '/_nested_scroll_view': (_) => NestedScrollViewScreen(),
        '/_notifiaction': (_) => NotificationScreen(),
        // ****
        '/about': (_) => MarkdownScreen('about.md', title: 'О проекте'),
        '/add_unit': (BuildContext context) =>
            AddUnitScreen(ModalRoute.of(context).settings.arguments),
        '/edit_unit': (BuildContext context) =>
            EditUnitScreen(ModalRoute.of(context).settings.arguments),
        '/faq': (_) => MarkdownScreen('faq.md', title: 'Вопросы и ответы'),
        '/feedback': (_) => FeedbackScreen(),
        '/forgot_password': (_) => ForgotPasswordScreen(),
        '/how_to_pay': (_) => HowToPayScreen(),
        '/how_it_works': (_) =>
            MarkdownScreen('how_it_works.md', title: 'Как это работает'),
        '/kinds': (BuildContext context) =>
            KindsScreen(ModalRoute.of(context).settings.arguments),
        '/ledger': (_) => LedgerScreen(),
        '/login': (_) => LoginScreen(),
        '/my_unit_map': (_) => MyUnitMapScreen(),
        '/pay': (_) => PayScreen(),
        '/search': (_) => SearchScreen(),
        '/settings': (_) => SettingsScreen(),
        '/showcase_map': (_) => ShowcaseMapScreen(),
        '/sign_up': (_) => SignUpScreen(),
        '/start': (_) => StartScreen(),
        '/start_map': (_) => StartMapScreen(),
        '/unit': (BuildContext context) =>
            UnitScreen(ModalRoute.of(context).settings.arguments),
        '/unit_map': (BuildContext context) =>
            UnitMapScreen(ModalRoute.of(context).settings.arguments),
        '/useful_tips': (_) =>
            MarkdownScreen('useful_tips.md', title: 'Полезные советы'),
        '/zoom': (BuildContext context) =>
            ZoomScreen(ModalRoute.of(context).settings.arguments),
      },
      // onGenerateRoute: (RouteSettings settings) {
      //   // if (settings.name == '/unit') {
      //   //   return Platform.isIOS
      //   //       ? TransparentCupertinoPageRoute(
      //   //           settings: settings,
      //   //           builder: (BuildContext context) => UnitScreen())
      //   //       : TransparentMaterialPageRoute(
      //   //           settings: settings,
      //   //           builder: (BuildContext context) => UnitScreen());
      //   // }
      //   print('onGenerateRoute: $settings');
      //   return null;
      // },
      // onUnknownRoute: (RouteSettings settings) => MaterialPageRoute<Null>(
      //   settings: settings,
      //   builder: (BuildContext context) => UnknownPage(settings.name),
      // ),
    );
    // result = AnnotatedRegion<SystemUiOverlayStyle>(
    //   value: SystemUiOverlayStyle(
    //     statusBarColor: Colors.white,
    //     // For Android.
    //     // Use [light] for white status bar and [dark] for black status bar.
    //     statusBarIconBrightness: Brightness.dark,
    //     // For iOS.
    //     // Use [dark] for white status bar and [light] for black status bar.
    //     statusBarBrightness: Brightness.dark,
    //   ),
    //   child: result,
    // );
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
        HomeShowcase.dataPool?.forEach((data) {
          data.dispose();
        });
        HomeShowcase.dataPool = null;
        HomeUnderway.dataPool?.forEach((data) {
          data.dispose();
        });
        HomeUnderway.dataPool = null;
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
    //If the design is based on the size of the Nexus 7 (2013)
    //If you want to set the font size is scaled according to the system's "font size" assist option
    // ScreenUtil.init(width: 1920, height: 1200, allowFontScaling: true);
    // printScreenInformation();
    final data = MediaQuery.of(context);
    return MediaQuery(
      data: data.copyWith(textScaleFactor: 1),
      child: child,
    );
    // TODO: Responsive App https://medium.com/nonstopio/let-make-responsive-app-in-flutter-e48428795476
  }

  // void printScreenInformation() {
  //   print('Device width dp:${ScreenUtil.screenWidth}'); //Device width
  //   print('Device height dp:${ScreenUtil.screenHeight}'); //Device height
  //   print(
  //       'Device pixel density:${ScreenUtil.pixelRatio}'); //Device pixel density
  //   print(
  //       'Bottom safe zone distance dp:${ScreenUtil.bottomBarHeight}'); //Bottom safe zone distance，suitable for buttons with full screen
  //   print(
  //       'Status bar height dp:${ScreenUtil.statusBarHeight}dp'); //Status bar height , Notch will be higher Unit dp
  //   print(
  //       'Ratio of actual width dp to design draft px:${ScreenUtil().scaleWidth}');
  //   print(
  //       'Ratio of actual height dp to design draft px:${ScreenUtil().scaleHeight}');
  //   print(
  //       'The ratio of font and width to the size of the design:${ScreenUtil().scaleWidth * ScreenUtil.pixelRatio}');
  //   print(
  //       'The ratio of height width to the size of the design:${ScreenUtil().scaleHeight * ScreenUtil.pixelRatio}');
  // }
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
