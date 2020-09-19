import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:minsk8/import.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:rxdart/subjects.dart';
import 'package:state_persistence/state_persistence.dart';
import 'package:bot_toast/bot_toast.dart';

// TODO: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_analytics
// TODO: на всех экранах, где не нужна клавиатура, вставить Scaffold.resizeToAvoidBottomInset: false,
// TODO: поменять все print(object) на debugPrint(String) ?
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

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotificationModel>();
final selectNotificationSubject = BehaviorSubject<String>();
NotificationAppLaunchDetails notificationAppLaunchDetails;

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    print('FlutterError.onError $details');
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
    // await initializeDateFormatting('en_US', null);
    await initializeDateFormatting('ru_RU', null);
    // runApp(
    //   DevicePreview(
    //     enabled: isInDebugMode,
    //     builder: (BuildContext context) => App(),
    //   ),
    // );
    runApp(AuthCheck());
  }, (error, stackTrace) {
    print('runZonedGuarded $error');
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
GraphQLClient client;
final localDeletedUnitIds = <String>{}; // ie Set()
final analytics = FirebaseAnalytics();
final analyticsObserver = FirebaseAnalyticsObserver(analytics: analytics);
final toastBuilder = BotToastInit();
final toastNavigatorObserver = BotToastNavigatorObserver();

class App extends StatelessWidget {
  App({this.authData});

  final AuthData authData;

  @override
  Widget build(BuildContext context) {
    // print('App build');
    Widget result = CommonMaterialApp(
      navigatorObservers: <NavigatorObserver>[
        analyticsObserver,
        toastNavigatorObserver,
      ],
      builder: (BuildContext context, Widget child) {
        // if (isInDebugMode) {
        //   child = DevicePreview.appBuilder(context, child);
        // }
        analytics.setCurrentScreen(screenName: '/app');
        client = GraphQLProvider.of(context).value;
        HomeShowcase.dataPool = kAllKinds
            .map((EnumModel kind) => ShowcaseData(kind.value))
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
            return FutureBuilder<bool>(
                future: authData.isLogin
                    ? _upsertMember(client)
                    : Future.value(true),
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Material(
                      child: Center(
                        child: Text('Update member...'),
                      ),
                    );
                  }
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      !snapshot.data) {
                    // TODO: [MVP] чтобы попробовать ещё раз - setState()
                    return Material(
                      child: Center(
                        child: Text('Кажется, что-то пошло не так?'),
                      ),
                    );
                  }
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
                        debugPrint(
                            getOperationExceptionToString(result.exception));
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
                        child: MediaQueryWrap(toastBuilder(context, child)),
                      );
                    },
                  );
                });
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
        '/about': (_) => ContentScreen('about.md', title: 'О проекте'),
        '/faq': (_) => ContentScreen('faq.md', title: 'Вопросы и ответы'),
        '/forgot_password': (_) => ForgotPasswordScreen(),
        '/how_it_works': (_) =>
            ContentScreen('how_it_works.md', title: 'Как это работает?'),
        '/ledger': (_) => LedgerScreen(),
        '/make_it_together': (_) =>
            ContentScreen('make_it_together.md', title: 'Сделаем это вместе!'),
        '/messages': (BuildContext context) => MessagesScreen(
            ModalRoute.of(context).settings.arguments
                as MessagesRouteArguments),
        '/search': (_) => SearchScreen(),
        '/start': (_) => StartScreen(),
        '/useful_tips': (_) =>
            ContentScreen('useful_tips.md', title: 'Полезные советы'),
      },
      onGenerateRoute: (RouteSettings settings) {
        final fullScreenDialogRoutes = <String, WidgetBuilder>{
          '/add_unit': (BuildContext context) => AddUnitScreen(
              ModalRoute.of(context).settings.arguments
                  as AddUnitRouteArguments),
          '/edit_unit': (BuildContext context) => EditUnitScreen(
              ModalRoute.of(context).settings.arguments
                  as EditUnitRouteArguments),
          '/feedback': (_) => FeedbackScreen(),
          '/how_to_pay': (_) => HowToPayScreen(),
          '/invite': (_) => InviteScreen(),
          '/kinds': (BuildContext context) => KindsScreen(
              ModalRoute.of(context).settings.arguments as KindsRouteArguments),
          // '/login': (_) => LoginScreen(),
          '/my_unit_map': (_) => MyUnitMapScreen(),
          '/payment': (_) => PaymentScreen(),
          '/settings': (_) => SettingsScreen(),
          '/showcase_map': (_) => ShowcaseMapScreen(),
          '/sign_up': (_) => SignUpScreen(),
          '/start_map': (_) => StartMapScreen(),
          '/unit': (BuildContext context) => UnitScreen(
              ModalRoute.of(context).settings.arguments as UnitRouteArguments),
          '/unit_map': (BuildContext context) => UnitMapScreen(
              ModalRoute.of(context).settings.arguments
                  as UnitMapRouteArguments),
          '/zoom': (BuildContext context) => ZoomScreen(
              ModalRoute.of(context).settings.arguments as ZoomRouteArguments),
        };
        if (fullScreenDialogRoutes.containsKey(settings.name)) {
          final widgetBuilder = fullScreenDialogRoutes[settings.name];
          return Platform.isIOS
              ? CupertinoPageRoute(
                  fullscreenDialog: true,
                  settings: settings,
                  builder: (BuildContext context) => widgetBuilder(context))
              : MaterialPageRoute(
                  fullscreenDialog: true,
                  settings: settings,
                  builder: (BuildContext context) => widgetBuilder(context));
        }
        // print('onGenerateRoute: $settings');
        return null;
      },
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
    // print(jsonEncode(parseIdToken(authData.token)));
    final httpLink = HttpLink(
      uri: 'https://$kGraphQLEndpoint',
    );
    final websocketLink = WebSocketLink(
      url: 'wss://$kGraphQLEndpoint',
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: kGraphQLWebsocketInactivityTimeout,
        initPayload: () async => {
          'headers': {'Authorization': 'Bearer ${authData.token}'}
        },
      ),
    );
    final authLink = AuthLink(
      getToken: () async => 'Bearer ${authData.token}',
    );
    final retryLink = Link(request: (
      Operation operation, [
      NextLink forward,
    ]) {
      StreamController<FetchResult> controller;
      Future<void> onListen() async {
        // print('onListen');
        await controller
            .addStream(refreshToken(controller, forward, operation).asStream());
        await controller.close();
      }

      controller = StreamController<FetchResult>.broadcast(onListen: onListen);
      return controller.stream;
    });
    result = GraphQLProvider(
      client: ValueNotifier(
        GraphQLClient(
          cache: InMemoryCache(),
          // cache: NormalizedInMemoryCache(
          //   dataIdFromObject: typenameDataIdFromObject,
          // ),
          link:
              retryLink.concat(authLink).concat(httpLink).concat(websocketLink),
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

  Future<bool> _upsertMember(GraphQLClient client) async {
    final options = MutationOptions(
      documentNode: Mutations.upsertMember,
      variables: {
        'display_name': authData.user.displayName,
        'photo_url': authData.user.photoUrl,
      },
      fetchPolicy: FetchPolicy.noCache,
    );
    return client
        .mutate(options)
        .timeout(kGraphQLMutationTimeoutDuration)
        .then<bool>((QueryResult result) {
      if (result.hasException) {
        throw result.exception;
      }
      if (result.data['insert_member']['affected_rows'] != 1) {
        throw 'Invalid insert_member.affected_rows';
      }
      appState['memberId'] = result.data['insert_member']['returning'][0]['id'];
      return true;
    }).catchError((error) {
      print('_upsertMember $error');
    });
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

class AuthData {
  AuthData({
    this.user,
    this.token,
    this.isLogin = false,
  });

  final FirebaseUser user;
  final String token;
  final bool isLogin;
}

class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  AuthData _authData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthData>(
      future: _authData == null ? _getAuthData() : Future.value(_authData),
      builder: (BuildContext context, AsyncSnapshot<AuthData> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            return CommonMaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text('Authentication...'),
                ),
              ),
            );
          case ConnectionState.done:
            if (snapshot.data == null) {
              return CommonMaterialApp(
                home: LoginScreen(onClose: (AuthData authData) {
                  setState(() {
                    _authData = authData;
                  });
                }),
              );
            }
            return App(authData: snapshot.data);
        }
        return null;
      },
    );
  }

  Future<AuthData> _getAuthData() async {
    try {
      final user = await FirebaseAuth.instance.currentUser();
      if (user == null) return null;
      final idToken = await user.getIdToken();
      return AuthData(user: user, token: idToken.token);
    } catch (error) {
      print('_getAuthData $error');
      return null;
    }
  }
}

class CommonMaterialApp extends StatelessWidget {
  CommonMaterialApp({
    this.navigatorObservers = const <NavigatorObserver>[],
    this.builder,
    this.home,
    this.initialRoute,
    this.routes = const <String, WidgetBuilder>{},
    this.onGenerateRoute,
    this.onUnknownRoute,
  });

  final List<NavigatorObserver> navigatorObservers;
  final TransitionBuilder builder;
  final Widget home;
  final String initialRoute;
  final Map<String, WidgetBuilder> routes;
  final RouteFactory onGenerateRoute;
  final RouteFactory onUnknownRoute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // print('App build');
    return MaterialApp(
      // debugShowCheckedModeBanner: isInDebugMode,
      navigatorObservers: navigatorObservers,
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
      // theme: ThemeData(
      //   //   primarySwatch: mapBoxBlue,
      //   //   visualDensity: VisualDensity.adaptivePlatformDensity
      // ),
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          elevation: kAppBarElevation,
          iconTheme: theme.iconTheme,
          actionsIconTheme: theme.iconTheme,
          color: theme.scaffoldBackgroundColor,
          textTheme: theme.textTheme, //.apply(fontSizeFactor: 0.8),
        ),
      ),
      builder: builder ??
          (BuildContext context, Widget child) => MediaQueryWrap(child),
      home: home,
      initialRoute: initialRoute,
      routes: routes,
      onGenerateRoute: onGenerateRoute,
      onUnknownRoute: onUnknownRoute,
    );
  }
}

// workaround for JWTExpired https://github.com/zino-app/graphql-flutter/issues/220#issuecomment-523108156
// see also https://hasura.io/blog/handling-graphql-hasura-errors-with-react/

Future<T> whenFirst<T>(Stream<T> source) async {
  try {
    await for (T value in source) {
      if (value != null) {
        return value;
      }
    }
    return null;
  } catch (error) {
    return Future.error(error);
  }
}

// TODO: extension FetchResultDump on FetchResult { dump() => this.fiels; }

Future<FetchResult> refreshToken(StreamController<FetchResult> controller,
    NextLink forward, Operation operation) async {
  try {
    // print('refreshToken');
    final mainStream = forward(operation);
    final firstEvent = await whenFirst(mainStream);
    if (firstEvent.errors != null && firstEvent.errors[0] != null) {
      print('firstEvent.errors[0] ${firstEvent.errors[0]}');
      print('firstEvent.statusCode ${firstEvent.statusCode}');
      // TODO: [MVP] перехватил ошибку, надо обработать (протухает через 1,5 часа)
      // https://github.com/zino-app/graphql-flutter/issues/220
      // ожидаю graphql-flutter V4, issue висит в roadmap
      // I/flutter ( 3382): firstEvent.errors[0] {extensions: {path: $, code: invalid-jwt}, message: Could not verify JWT: JWTExpired}
      // I/flutter ( 3382): firstEvent.statusCode null
      // I/flutter ( 3382): GraphQL Errors:
      // I/flutter ( 3382): Could not verify JWT: JWTExpired: Undefined location
    }
    // print('firstEvent.data ${firstEvent.data}');
    return firstEvent;
  } catch (error, stackTrace) {
    print('refreshToken error $error');
    print('refreshToken stackTrace $stackTrace');
    return Future.error(error);
    // Logger.root.severe(error.toString());
    // if (error is ClientException && error.message.contains("401") && (await tokenManager.hasTokens())) {
    //   // Logger.root.info('User logged out. But token persents. Refreshing token');
    //   final Token token = await tokenAPI.refreshToken();
    //   if (token.isValid()) {
    //     await tokenManager.setAccessToken(token.accessToken);
    //     await tokenManager.setRefreshToken(token.refreshToken);
    //     return whenFirst(forward(operation));
    //   } else {
    //     await tokenManager.removeCredentials();
    //     return whenFirst(forward(operation));
    //   }
    // } else {
    //   return Future.error(error);
    // }
  }
}
