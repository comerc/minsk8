import 'dart:async';
// import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:rxdart/subjects.dart';
import 'package:state_persistence/state_persistence.dart';
import 'package:minsk8/import.dart';
// import 'package:flutter/rendering.dart';

// TODO: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_analytics
// TODO: на всех экранах, где не нужна клавиатура, вставить Scaffold.resizeToAvoidBottomInset: false,
// TODO: timeout для подписок GraphQL, смотри примеры
// TODO: Image.asset автоматически показывает версию файла в зависимости от плотности пикселей устройства: - images/dash.png или - images/2x/dash.png
// TODO: Убрать лишние Material и InkWell
// TODO: выставить textColor для кнопок, чтобы получить цветной InkWell (см. еще на MaterialButton.splashColor)
// TODO: auto_animated
// TODO: профилирование анимации debugProfileBuildsEnabled: true,
// TODO: проверить везде fit: StackFit.expand,
// TODO: бейджики для активных участников
// TODO: выходящий за пределы экрана InkWell для системной кнопки Close - OverflowBox
// TODO: автоматизация локализации https://medium.com/in-the-pocket-insights/localising-flutter-applications-and-automating-the-localisation-process-752a26fe179c
// TODO: сторонний вариант локализации https://github.com/aissat/easy_localization
// TODO: пока загружается аватарка - показывать ожидание
// TODO: добавить google-services-info.plist https://support.google.com/firebase/answer/7015592?hl=ru
// TODO: flutter telegram-auth
// TODO: закруглить кнопки и диалоги, как в https://console.firebase.google.com
// TODO: [MVP] Step-by-step guide to Android code signing and code signing https://blog.codemagic.io/the-simple-guide-to-android-code-signing/
// TODO: если не было активности в приложение какое-то время, а потом запросить refresh для NoticeData, то "Could not verify JWT"
// TODO: выдавать поощрения тем, кто первый сообщил об ошибке (но можно получить недовольных - нужно вести публичный журнал зарегистрированных ошибок)
// TODO: применить const для EdgeInsets и подобных случаев: https://habr.com/ru/post/501804/
// TODO: вынести в виджеты ./widgets "условный body" из виджетов ./screen
// TODO: синхронизировать между несколькими приложениями одного участника перманентные данные о Profile, MyWishes, MyBlocks
// TODO: заменить Snackbar на BotToast для асинхронных операций
// TODO: [MVP] Text('', overflow: TextOverflow.fade, softWrap: false)
// TODO: объявить имена аргументов при типизации callback-ов: void Function(int) -> void Function(int index)
// TODO: как мокать модули, подобно JS? (для применения в тестах вместо DI) https://railsware.com/blog/mocking-es6-module-import-without-dependency-injection/

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotificationModel>();
final selectNotificationSubject = BehaviorSubject<String>();
NotificationAppLaunchDetails notificationAppLaunchDetails;

// don't use async for main!
void main() {
  // debugPaintSizeEnabled = true;
  FlutterError.onError = (FlutterErrorDetails details) {
    out('FlutterError.onError $details');
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
    final initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
    // of the `IOSFlutterLocalNotificationsPlugin` class
    final initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotificationModel(
              id: id, title: title, body: body, payload: payload));
        });
    final initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        out('notification payload: $payload');
      }
      selectNotificationSubject.add(payload);
    });
    await Firebase.initializeApp();
    // TODO: locale autodetect
    // await initializeDateFormatting('en_US', null);
    await initializeDateFormatting('ru_RU');
    // runApp(
    //   DevicePreview(
    //     enabled: isInDebugMode,
    //     builder: (BuildContext context) => App(),
    //   ),
    // );
    // runApp(AuthCheck());
    runApp(App());
  }, (error, stackTrace) {
    out('runZonedGuarded $error');
    // Whenever an error occurs, call the `_reportError` function. This sends
    // Dart errors to the dev console or Sentry depending on the environment.
    // _reportError(error, stackTrace);
  });
}

// Future<void> _reportError(dynamic error, dynamic stackTrace) async {
//   // Print the exception to the console.
//   out('Caught error: $error');
//   if (isInDebugMode) {
//     // Print the full stacktrace in debug mode.
//     out(stackTrace);
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
GraphQLClient client;
final localDeletedUnitIds = <String>{}; // ie Set()

var _analytics = FirebaseAnalytics();
FirebaseAnalytics get analytics {
  return _analytics ??= FirebaseAnalytics();
}

class App extends StatelessWidget {
  // App({this.authData});

  // final AuthData authData;

  @override
  Widget build(BuildContext context) {
    // out('App build');
    Widget result = CommonMaterialApp(
      builder: (BuildContext context, Widget child) {
        // if (isInDebugMode) {
        //   child = DevicePreview.appBuilder(context, child);
        // }
        analytics.setCurrentScreen(screenName: '/app');
        client = GraphQLProvider.of(context).value;
        HomeShowcase.dataPool = [...MetaKindValue.values, ...KindValue.values]
            .map((dynamic value) => ShowcaseData(value))
            .toList();
        HomeUnderway.dataPool = UnderwayValue.values
            .map((UnderwayValue value) => UnderwayData(value))
            .toList();
        HomeInterplay.dataPool = [
          ChatData(),
          // [
          //   ChatData(client, StageValue.ready),
          //   ChatData(client, StageValue.cancel),
          //   ChatData(client, StageValue.success),
          // ],
          NoticeData(),
        ];
        LedgerScreen.sourceList = LedgerData();
        return PersistedStateBuilder(
          builder:
              (BuildContext context, AsyncSnapshot<PersistedData> snapshot) {
            if (!snapshot.hasData) {
              return Material(
                child: Center(
                  child: Text('Loading state...'),
                ),
              );
            }
            appState = PersistedAppState.of(context);
            // return FutureBuilder<bool>(
            //   future:
            //       authData.isLogin ? _upsertMember(client) : Future.value(true),
            //   builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            //     if (snapshot.connectionState != ConnectionState.done) {
            //       return Material(
            //         child: Center(
            //           child: Text('Update member...'),
            //         ),
            //       );
            //     }
            //     if (snapshot.hasError || !snapshot.hasData || !snapshot.data) {
            //       // TODO: [MVP] чтобы попробовать ещё раз - setState()
            //       return Material(
            //         child: Center(
            //           child: Text('Кажется, что-то пошло не так?'),
            //         ),
            //       );
            //     }
            return Query(
              options: QueryOptions(
                documentNode: Queries.getProfile,
                variables: {'member_id': appState['memberId']},
                fetchPolicy: FetchPolicy.noCache,
              ),
              // Just like in apollo refetch() could be used to manually trigger a refetch
              // while fetchMore() can be used for pagination purpose
              builder: (QueryResult result,
                  {VoidCallback refetch, FetchMore fetchMore}) {
                if (result.hasException) {
                  out(getOperationExceptionToString(result.exception));
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
                  providers: <SingleChildWidget>[
                    ChangeNotifierProvider<ProfileModel>(
                      create: (_) => ProfileModel.fromJson(
                        result.data['profile'] as Map<String, dynamic>,
                      ),
                    ),
                    ChangeNotifierProvider<MyWishesModel>(
                      create: (_) => MyWishesModel.fromJson(
                        result.data as Map<String, dynamic>,
                      ),
                    ),
                    ChangeNotifierProvider<MyBlocksModel>(
                      create: (_) => MyBlocksModel.fromJson(
                        result.data as Map<String, dynamic>,
                      ),
                    ),
                    ChangeNotifierProvider<DistanceModel>(
                        create: (_) => DistanceModel()),
                    ChangeNotifierProvider<MyUnitMapModel>(
                      create: (_) => MyUnitMapModel(),
                    ),
                    ChangeNotifierProvider<AppBarModel>(
                      create: (_) => AppBarModel(),
                    ),
                    ChangeNotifierProvider<VersionModel>(
                      create: (_) => VersionModel(),
                    ),
                  ],
                  child: child,
                );
              },
            );
            //   },
            // );
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
        '/_listview': (_) => ListViewScreen(),
        '/_load_data': (_) => LoadDataScreen(),
        '/_nested_scroll_view': (_) => NestedScrollViewScreen(),
        '/_notifiaction': (_) => NotificationScreen(),
        // ****
        '/start': (_) => StartScreen(),
      },
      // onGenerateRoute: (RouteSettings settings) {
      //   out('onGenerateRoute: $settings');
      //   return null;
      // },
      // onUnknownRoute: (RouteSettings settings) => MaterialPageRoute<void>(
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
    // out(jsonEncode(parseIdToken(authData.token)));
    final httpLink = HttpLink(
      uri: 'https://$kGraphQLEndpoint',
      headers: {
        'X-Hasura-Role': 'user',
        'X-Hasura-User-Id': kFakeMemberId,
      },
    );
    // TODO: включить HASURA_GRAPHQL_JWT_SECRET
    // TODO: переключить HASURA_GRAPHQL_UNAUTHORIZED_ROLE на guest
    // final websocketLink = WebSocketLink(
    //   url: 'wss://$kGraphQLEndpoint',
    //   config: SocketClientConfig(
    //     inactivityTimeout: kGraphQLWebsocketInactivityTimeout,
    //     initPayload: () async => {
    //       'headers': {'Authorization': 'Bearer ${authData.token}'}
    //     },
    //   ),
    // );
    // final authLink = AuthLink(
    //   getToken: () async => 'Bearer ${authData.token}',
    // );
    // TODO: [MVP] fresh_graphql
    // https://stackoverflow.com/questions/61708776/how-to-retry-a-request-on-graphqlerror-in-graphql-flutter
    // final retryLink = Link(request: (
    //   Operation operation, [
    //   NextLink forward,
    // ]) {
    //   StreamController<FetchResult> controller;
    //   Future<void> onListen() async {
    //     // out('onListen');
    //     await controller
    //         .addStream(refreshToken(controller, forward, operation).asStream());
    //     await controller.close();
    //   }

    //   controller = StreamController<FetchResult>.broadcast(onListen: onListen);
    //   return controller.stream;
    // });
    result = GraphQLProvider(
      client: ValueNotifier(
        GraphQLClient(
          cache: InMemoryCache(),
          // cache: NormalizedInMemoryCache(
          //   dataIdFromObject: typenameDataIdFromObject,
          // ),
          link: httpLink,
          // link:
          //     retryLink.concat(authLink).concat(httpLink).concat(websocketLink),
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
    result = _LifeCycleManager(
      onInitState: () {},
      onDispose: () {
        for (final data in HomeShowcase.dataPool) {
          data.dispose();
        }
        HomeShowcase.dataPool = null;
        for (final data in HomeUnderway.dataPool) {
          data.dispose();
        }
        HomeUnderway.dataPool = null;
      },
      child: result,
    );
    return result;
  }
}

// Future<bool> _upsertMember(AuthData authData) {
//   final options = MutationOptions(
//     documentNode: Mutations.upsertMember,
//     variables: {
//       'display_name': authData.user.displayName,
//       'photo_url': authData.user.photoUrl,
//     },
//     fetchPolicy: FetchPolicy.noCache,
//   );
//   return client
//       .mutate(options)
//       .timeout(kGraphQLMutationTimeoutDuration)
//       .then<bool>((QueryResult result) {
//     if (result.hasException) {
//       throw result.exception;
//     }
//     if (result.data['insert_member']['affected_rows'] != 1) {
//       throw 'Invalid insert_member.affected_rows';
//     }
//     appState['memberId'] = result.data['insert_member']['returning'][0]['id'];
//     return true;
//   }).catchError((error) {
//     out('_upsertMember $error');
//   });
// }

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
  //   out('Device width dp:${ScreenUtil.screenWidth}'); //Device width
  //   out('Device height dp:${ScreenUtil.screenHeight}'); //Device height
  //   out(
  //       'Device pixel density:${ScreenUtil.pixelRatio}'); //Device pixel density
  //   out(
  //       'Bottom safe zone distance dp:${ScreenUtil.bottomBarHeight}'); //Bottom safe zone distance，suitable for buttons with full screen
  //   out(
  //       'Status bar height dp:${ScreenUtil.statusBarHeight}dp'); //Status bar height , Notch will be higher Unit dp
  //   out(
  //       'Ratio of actual width dp to design draft px:${ScreenUtil().scaleWidth}');
  //   out(
  //       'Ratio of actual height dp to design draft px:${ScreenUtil().scaleHeight}');
  //   out(
  //       'The ratio of font and width to the size of the design:${ScreenUtil().scaleWidth * ScreenUtil.pixelRatio}');
  //   out(
  //       'The ratio of height width to the size of the design:${ScreenUtil().scaleHeight * ScreenUtil.pixelRatio}');
  // }
}

// String typenameDataIdFromObject(Object object) {
//   if (object is Map<String, Object> && object.containsKey('__typename')) {
//     if (object['__typename'] == 'profile') {
//       final member = object['member'] as Map<String, Object>;
//       out('profile/${member['id']}');
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

class AuthData {
  AuthData({
    this.user,
    this.token,
    this.isLogin = false,
  });

  final firebase_auth.User user;
  final String token;
  final bool isLogin;
}

// class AuthCheck extends StatefulWidget {
//   @override
//   _AuthCheckState createState() => _AuthCheckState();
// }

// class _AuthCheckState extends State<AuthCheck> {
//   AuthData _authData;

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<AuthData>(
//       future: _authData == null ? _getAuthData() : Future.value(_authData),
//       builder: (BuildContext context, AsyncSnapshot<AuthData> snapshot) {
//         switch (snapshot.connectionState) {
//           case ConnectionState.none:
//           case ConnectionState.waiting:
//           case ConnectionState.active:
//             return CommonMaterialApp(
//               home: Scaffold(
//                 body: Center(
//                   child: Text('Authentication...'),
//                 ),
//               ),
//             );
//           case ConnectionState.done:
//             if (snapshot.data == null) {
//               return CommonMaterialApp(
//                 home: LoginScreen(onClose: (AuthData authData) {
//                   setState(() {
//                     _authData = authData;
//                   });
//                 }),
//               );
//             }
//             return App(authData: snapshot.data);
//         }
//         return null;
//       },
//     );
//   }

//   Future<AuthData> _getAuthData() async {
//     try {
//       // TODO: провести эксперимент - будет ли работать в offline?
//       final user = await FirebaseAuth.instance.currentUser();
//       if (user == null) return null;
//       final idToken = await user.getIdToken();
//       return AuthData(user: user, token: idToken.token);
//     } catch (error) {
//       out('_getAuthData $error');
//       return null;
//     }
//   }
// }

final navigatorKey = GlobalKey<NavigatorState>();
NavigatorState get navigator => navigatorKey.currentState;

class CommonMaterialApp extends StatelessWidget {
  CommonMaterialApp({
    // this.navigatorObservers = const <NavigatorObserver>[],
    this.builder,
    this.home,
    this.initialRoute,
    this.routes = const <String, WidgetBuilder>{},
    // this.onGenerateRoute,
    // this.onUnknownRoute,
  });

  // final List<NavigatorObserver> navigatorObservers;
  final TransitionBuilder builder;
  final Widget home;
  final String initialRoute;
  final Map<String, WidgetBuilder> routes;
  // final RouteFactory onGenerateRoute;
  // final RouteFactory onUnknownRoute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // out('App build');
    return MaterialApp(
      // debugShowCheckedModeBanner: isInDebugMode,
      navigatorKey: navigatorKey,
      navigatorObservers: <NavigatorObserver>[
        FirebaseAnalyticsObserver(analytics: analytics),
        BotToastNavigatorObserver(),
      ],
      // locale: isInDebugMode ? DevicePreview.of(context).locale : null,
      // locale: DevicePreview.of(context).locale,
      // localizationsDelegates: [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      // ],
      // supportedLocales: [
      //   Locale('en', 'US'), // English
      //   Locale('ru', 'RU'), // Russian
      // ],
      title: 'minsk8',
      theme: theme.copyWith(
        appBarTheme: theme.appBarTheme.copyWith(
          elevation: kAppBarElevation,
          iconTheme: theme.iconTheme,
          // actionsIconTheme: theme.iconTheme,
          color: theme.scaffoldBackgroundColor,
          textTheme: theme.textTheme, //.apply(fontSizeFactor: 0.8),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // primarySwatch: Colors.blue,
        // textTheme: GoogleFonts.montserratTextTheme(),
      ),
      builder: (BuildContext context, Widget child) {
        final result = builder == null ? child : builder(context, child);
        return MediaQueryWrap(BotToastInit()(context, result));
      },
      home: home,
      initialRoute: initialRoute,
      routes: routes,
      // onGenerateRoute: onGenerateRoute,
      // onUnknownRoute: onUnknownRoute,
    );
  }
}

// workaround for JWTExpired https://github.com/zino-app/graphql-flutter/issues/220#issuecomment-523108156
// see also https://hasura.io/blog/handling-graphql-hasura-errors-with-react/

// Future<T> whenFirst<T>(Stream<T> source) async {
//   try {
//     await for (final T value in source) {
//       if (value != null) {
//         return value;
//       }
//     }
//     return null;
//   } catch (error) {
//     return Future.error(error);
//   }
// }

// TODO: extension FetchResultDump on FetchResult { dump() => this.fiels; }

// Future<FetchResult> refreshToken(StreamController<FetchResult> controller,
//     NextLink forward, Operation operation) async {
//   try {
//     // out('refreshToken');
//     final mainStream = forward(operation);
//     final firstEvent = await whenFirst(mainStream);
//     if (firstEvent.errors != null && firstEvent.errors[0] != null) {
//       out('firstEvent.errors[0] ${firstEvent.errors[0]}');
//       out('firstEvent.statusCode ${firstEvent.statusCode}');
//       // TODO: [MVP] перехватил ошибку, надо обработать (протухает через 1,5 часа)
//       // https://github.com/zino-app/graphql-flutter/issues/220
//       // ожидаю graphql-flutter V4, issue висит в roadmap
//       // I/flutter ( 3382): firstEvent.errors[0] {extensions: {path: $, code: invalid-jwt}, message: Could not verify JWT: JWTExpired}
//       // I/flutter ( 3382): firstEvent.statusCode null
//       // I/flutter ( 3382): GraphQL Errors:
//       // I/flutter ( 3382): Could not verify JWT: JWTExpired: Undefined location
//     }
//     // out('firstEvent.data ${firstEvent.data}');
//     return firstEvent;
//   } catch (error, stackTrace) {
//     out('refreshToken error $error');
//     out('refreshToken stackTrace $stackTrace');
//     return Future.error(error);
//     // Logger.root.severe(error.toString());
//     // if (error is ClientException && error.message.contains("401") && (await tokenManager.hasTokens())) {
//     //   // Logger.root.info('User logged out. But token persents. Refreshing token');
//     //   final Token token = await tokenAPI.refreshToken();
//     //   if (token.isValid()) {
//     //     await tokenManager.setAccessToken(token.accessToken);
//     //     await tokenManager.setRefreshToken(token.refreshToken);
//     //     return whenFirst(forward(operation));
//     //   } else {
//     //     await tokenManager.removeCredentials();
//     //     return whenFirst(forward(operation));
//     //   }
//     // } else {
//     //   return Future.error(error);
//     // }
//   }
// }

class _LifeCycleManager extends StatefulWidget {
  _LifeCycleManager({Key key, this.child, this.onInitState, this.onDispose})
      : super(key: key);

  final Widget child;
  final VoidCallback onInitState;
  final VoidCallback onDispose;

  @override
  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<_LifeCycleManager>
    with WidgetsBindingObserver {
  // List<StoppableService> services = [
  //   locator<LocationService>(),
  // ];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    widget.onInitState();
  }

  @override
  void dispose() {
    widget.onDispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // out('lyfecycle state = $state');
    // for (final service in services) {
    //   if (state == AppLifecycleState.resumed) {
    //     service.start();
    //   } else {
    //     service.stop();
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// abstract class StoppableService {
//   bool _serviceStoped = false;
//   bool get serviceStopped => _serviceStoped;

//   @mustCallSuper
//   void stop() {
//     _serviceStoped = true;
//   }

//   @mustCallSuper
//   void start() {
//     _serviceStoped = false;
//   }
// }

// class LocationService extends StoppableService {
//   @override
//   void start() {
//     super.start();
//     // start subscription again
//   }

//   @override
//   void stop() {
//     super.stop();
//     // cancel stream subscription
//   }
// }

class MainDrawer extends StatelessWidget {
  final routes = [
    {
      'title': 'Animation',
      'routeName': '/_animation',
    },
    {
      'title': 'Custom Dialog',
      'routeName': '/_custom_dialog',
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
    // {
    //   'title': 'About',
    //   'routeName': '/about',
    // },
    // {
    //   'title': 'Add Unit',
    //   'routeName': '/add_unit',
    //   'arguments': AddUnitRouteArguments(kind: KindValue.technics),
    // },
    // {
    //   'title': 'Edit Unit',
    //   'routeName': '/edit_unit',
    //   'arguments': EditUnitRouteArguments(0),
    // },
    // {
    //   'title': 'FAQ',
    //   'routeName': '/faq',
    // },
    // {
    //   'title': 'Forgot Password',
    //   'routeName': '/forgot_password',
    // },
    // {
    //   'title': 'Unit',
    //   'routeName': '/unit',
    //   // ignore: top_level_function_literal_block
    //   'arguments': (BuildContext context) async {
    //     final profile = Provider.of<ProfileModel>(context, listen: false);
    //     final options = QueryOptions(
    //       documentNode: Queries.getUnit,
    //       variables: {'id': profile.member.units[0].id},
    //       fetchPolicy: FetchPolicy.noCache,
    //     );
    //     // final client = GraphQLProvider.of(context).value;
    //     final result =
    //         await client.query(options).timeout(kGraphQLQueryTimeoutDuration);
    //     if (result.hasException) {
    //       throw result.exception;
    //     }
    //     final unit =
    //         UnitModel.fromJson(result.data['unit'] as Map<String, dynamic>);
    //     return UnitRouteArguments(
    //       unit,
    //       member: unit.member,
    //     );
    //   },
    // },
    // {
    //   'title': 'Select Kind(s)',
    //   'routeName': '/kinds',
    //   'arguments': KindsRouteArguments(KindValue.pets),
    // },
    // {
    //   'title': 'Ledger',
    //   'routeName': '/ledger',
    // },
    // {
    //   'title': 'Messages',
    //   'routeName': '/messages',
    //   // ignore: top_level_function_literal_block
    //   'arguments': (BuildContext context) async {
    //     final options = QueryOptions(
    //       documentNode: Queries.getChats,
    //       fetchPolicy: FetchPolicy.noCache,
    //     );
    //     // final client = GraphQLProvider.of(context).value;
    //     final result =
    //         await client.query(options).timeout(kGraphQLQueryTimeoutDuration);
    //     if (result.hasException) {
    //       throw result.exception;
    //     }
    //     final item =
    //         ChatModel.fromJson(result.data['chats'][0] as Map<String, dynamic>);
    //     return MessagesRouteArguments(
    //       chat: item,
    //     );
    //   },
    // },
    // {
    //   'title': 'Login',
    //   'routeName': '/login',
    // },
    // {
    //   'title': 'My Units',
    //   'routeName': '/my_units',
    // },
    // {
    //   'title': 'Pay',
    //   'routeName': '/pay',
    // },
    // {
    //   'title': 'Search',
    //   'routeName': '/search',
    // },
    // {
    //   'title': 'Settings',
    //   'routeName': '/settings',
    // },
    // {
    //   'title': 'Showcase Map',
    //   'routeName': '/showcase_map',
    // },
    // {
    //   'title': 'Sign Up',
    //   'routeName': '/sign_up',
    // },
    // {
    //   'title': 'Start Map',
    //   'routeName': '/start_map',
    // },
    // {
    //   'title': 'Useful Tips',
    //   'routeName': '/useful_tips',
    // },
    // {
    //   'title': 'Wishes',
    //   'routeName': '/wishes',
    // },
  ];

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
                navigator.popUntil(
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
            itemCount: routes.length,
            itemBuilder: (BuildContext context, int index) {
              final mainRoute = routes[index];
              return ListTile(
                title: Text(mainRoute['title'] as String),
                selected: currentRouteName == mainRoute['routeName'],
                onTap: () async {
                  navigator.popUntil(
                      (route) => route.settings.name == kInitialRouteName);
                  final arguments = (mainRoute['arguments'] is Function)
                      ? await (mainRoute['arguments'] as Function)(context)
                      : mainRoute['arguments'];
                  if (arguments == null) {
                    // ignore: unawaited_futures
                    navigator.pushNamed(
                      mainRoute['routeName'] as String,
                    );
                    return;
                  }
                  // ignore: unawaited_futures
                  navigator.pushNamed(
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
