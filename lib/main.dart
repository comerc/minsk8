import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:graphql/client.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:rxdart/subjects.dart';
import 'package:state_persistence/state_persistence.dart';
// import 'package:flutter/scheduler.dart' show timeDilation;
// import 'package:flutter/rendering.dart';
import 'package:minsk8/import.dart';

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
// TODO: добавить blur для оверлея диалогов, как в OBS Blade
// TODO: (for PersistedQueriesLink) Support for persisted queries https://github.com/hasura/graphql-engine/issues/273
// TODO: Reduce shader compilation jank on mobile https://flutter.dev/docs/perf/rendering/shader
// TODO: Обернуть требуемые экраны в SafeArea (проверить на iPhone X)
// TODO: [MVP] включить HASURA_GRAPHQL_JWT_SECRET
// TODO: [MVP] переключить HASURA_GRAPHQL_UNAUTHORIZED_ROLE на guest

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// Streams are created so that app can respond to notification-related events
// since the plugin is initialised in the `main` function
final didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotificationModel>();
final selectNotificationSubject = BehaviorSubject<String>();
NotificationAppLaunchDetails notificationAppLaunchDetails;

// don't use async for main!
void main() {
  // timeDilation = 2.0; // Will slow down animations by a factor of two
  // debugPaintSizeEnabled = true;
  // from https://flutter.dev/docs/cookbook/maintenance/error-reporting
  FlutterError.onError = (FlutterErrorDetails details) {
    out('FlutterError.onError $details');
    if (isInDebugMode) {
      // In development mode, simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode, report to the application zone to report to Sentry.
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    final initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    // Note: permissions aren't requested here just to demonstrate
    // that can be done later using the `requestPermissions()` method
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
    runApp(App());
  }, (error, stackTrace) {
    out('**** runZonedGuarded ****');
    out('$error');
    out('$stackTrace');
    // TODO: [MVP] отправлять ошибки в Sentry (или Firebase Crashlytics)
  });
}

// TODO: вынести в AppCubit и заменить на hydrated_bloc
PersistedData appState;
// TODO: удалить, когда везде будет через BLoC
GraphQLClient client = createClient();
// TODO: вынести в ProfileCubit
final localDeletedUnitIds = <String>{}; // ie Set()

var _analytics = FirebaseAnalytics();
FirebaseAnalytics get analytics {
  return _analytics ??= FirebaseAnalytics();
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget result = CommonMaterialApp(
      builder: (BuildContext context, Widget child) {
        // analytics.setCurrentScreen(screenName: '/app');
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
            return FutureBuilder<Map<String, dynamic>>(
              future: _loadProfileData(),
              builder: (BuildContext context,
                  AsyncSnapshot<Map<String, dynamic>> snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Material(
                    child: Center(
                      child: Text('Loading profile...'),
                    ),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Material(
                    child: InkWell(
                      // onTap: refetch,
                      child: Center(
                        child: Text('Кажется, что-то пошло не так?'),
                      ),
                    ),
                  );
                }
                return MultiProvider(
                  providers: <SingleChildWidget>[
                    ChangeNotifierProvider<ProfileModel>(
                      create: (_) => ProfileModel.fromJson(
                        snapshot.data['profile'] as Map<String, dynamic>,
                      ),
                    ),
                    ChangeNotifierProvider<MyWishesModel>(
                      create: (_) => MyWishesModel.fromJson(snapshot.data),
                    ),
                    ChangeNotifierProvider<MyBlocksModel>(
                      create: (_) => MyBlocksModel.fromJson(snapshot.data),
                    ),
                  ],
                  child: child,
                );
              },
            );
          },
        );
      },
      home: HomeScreen(),
      // TODO: [MVP] восстановить функционал /start
      // initialRoute: kInitialRouteName,
      // routes: <String, WidgetBuilder>{
      //   '/_animation': (_) => AnimationScreen(),
      //   '/_custom_dialog': (_) => CustomDialogScreen(),
      //   '/_image_capture': (_) => ImageCaptureScreen(),
      //   '/_image_pinch': (_) => ImagePinchScreen(),
      //   '/_listview': (_) => ListViewScreen(),
      //   '/_nested_scroll_view': (_) => NestedScrollViewScreen(),
      //   '/_notification': (_) => NotificationScreen(),
      //   // ****
      //   '/start': (_) => StartScreen(),
      // },
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
    result = PersistedAppState(
      storage: JsonFileStorage(),
      child: result,
    );
    result = _LifeCycleManager(
      onInitState: () {
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
      },
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
    result = MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<DistanceModel>(create: (_) => DistanceModel()),
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
      child: result,
    );
    return result;
  }
}

Future<Map<String, dynamic>> _loadProfileData() async {
  final options = QueryOptions(
    document: addFragments(Queries.getProfile),
    variables: {'member_id': kFakeMemberId},
    fetchPolicy: FetchPolicy.noCache,
  );
  final result =
      await client.query(options).timeout(kGraphQLQueryTimeoutDuration);
  if (result.hasException) {
    throw result.exception;
  }
  return result.data;
}

// публично для тестирования
GraphQLClient createClient() {
  final httpLink = HttpLink(
    'https://$kGraphQLEndpoint',
    defaultHeaders: {
      'X-Hasura-Role': 'user',
      'X-Hasura-User-Id': kFakeMemberId,
    },
  );
  // final authLink = AuthLink(
  //   getToken: () async {
  //     final idToken = await FirebaseAuth.instance.currentUser.getIdToken(true);
  //     return 'Bearer $idToken';
  //   },
  // );
  // var link = authLink.concat(httpLink);
  // final websocketLink = WebSocketLink(
  //   'wss://$kGraphQLEndpoint',
  //   config: SocketClientConfig(
  //     initialPayload: () async {
  //       final idToken =
  //           await FirebaseAuth.instance.currentUser.getIdToken(true);
  //       return {
  //         'headers': {'Authorization': 'Bearer $idToken'},
  //       };
  //     },
  //   ),
  // );
  // // split request based on type
  // link = Link.split(
  //   (request) => request.isSubscription,
  //   websocketLink,
  //   link,
  // );
  return GraphQLClient(
    cache: GraphQLCache(),
    link: httpLink,
  );
}

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
    // TODO: responsive app
    // - https://pub.dev/packages/flutter_screenutil
    // - https://pub.dev/packages/device_preview
    // - https://medium.com/nonstopio/let-make-responsive-app-in-flutter-e48428795476
    // - https://github.com/Codelessly/ResponsiveFramework
    // - https://pub.dev/packages/responsive_builder
  }

  // void printScreenInformation() {
  //   out('Device width dp:${ScreenUtil.screenWidth}'); //Device width
  //   out('Device height dp:${ScreenUtil.screenHeight}'); //Device height
  //   out('Device pixel density:${ScreenUtil.pixelRatio}'); //Device pixel density
  //   out('Bottom safe zone distance dp:${ScreenUtil.bottomBarHeight}'); //Bottom safe zone distance，suitable for buttons with full screen
  //   out('Status bar height dp:${ScreenUtil.statusBarHeight}dp'); //Status bar height , Notch will be higher Unit dp
  //   out('Ratio of actual width dp to design draft px:${ScreenUtil().scaleWidth}');
  //   out('Ratio of actual height dp to design draft px:${ScreenUtil().scaleHeight}');
  //   out('The ratio of font and width to the size of the design:${ScreenUtil().scaleWidth * ScreenUtil.pixelRatio}');
  //   out('The ratio of height width to the size of the design:${ScreenUtil().scaleHeight * ScreenUtil.pixelRatio}');
  // }
}

// TODO: сгенирировать цветовую палитру в MaterialColor
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

// TODO: провести эксперимент - будет ли работать в offline user.getIdToken(true)?

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
        Widget result = child;
        result = MediaQueryWrap(result);
        result = BotToastInit()(context, result);
        if (builder != null) {
          result = builder(context, result);
        }
        return result;
      },
      home: home,
      initialRoute: initialRoute,
      routes: routes,
      // onGenerateRoute: onGenerateRoute,
      // onUnknownRoute: onUnknownRoute,
    );
  }
}

// code from https://medium.com/flutter-community/build-a-lifecycle-manager-to-manage-your-services-b9c928d3aed7
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
