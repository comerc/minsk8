import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:graphql/client.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:rxdart/subjects.dart';
import 'package:state_persistence/state_persistence.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:flutter/scheduler.dart' show timeDilation;
// import 'package:flutter/rendering.dart';
import 'package:minsk8/import.dart';

// TODO: реферальный QR-Code (см. Binance Futures в теслаголиках)
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
// TODO: локализация https://flutter.dev/docs/development/accessibility-and-localization/internationalization
// TODO: пока загружается аватарка - показывать ожидание
// TODO: добавить google-services-info.plist https://support.google.com/firebase/answer/7015592?hl=ru
// TODO: закруглить кнопки и диалоги, как в https://console.firebase.google.com
// TODO: [MVP] Step-by-step guide to Android code signing and code signing https://blog.codemagic.io/the-simple-guide-to-android-code-signing/
// TODO: если не было активности в приложение какое-то время, а потом запросить refresh для NoticeData, то "Could not verify JWT"
// TODO: выдавать поощрения тем, кто первый сообщил об ошибке (но можно получить недовольных - нужно вести публичный журнал зарегистрированных ошибок)
// TODO: вынести в виджеты ./widgets "условный body" из виджетов ./screen
// TODO: синхронизировать между несколькими приложениями одного участника перманентные данные о Profile, MyWishes, MyBlocks
// TODO: заменить Snackbar на BotToast для асинхронных операций (или применить asuka?)
// TODO: [MVP] Text('', overflow: TextOverflow.fade, softWrap: false)
// TODO: объявить имена аргументов при типизации callback-ов: void Function(int) -> void Function(int index)
// TODO: как мокать модули, подобно JS? (для применения в тестах вместо DI) https://railsware.com/blog/mocking-es6-module-import-without-dependency-injection/
// TODO: добавить blur для оверлея диалогов, как в OBS Blade
// TODO: (for PersistedQueriesLink) Support for persisted queries https://github.com/hasura/graphql-engine/issues/273
// TODO: Reduce shader compilation jank on mobile https://flutter.dev/docs/perf/rendering/shader
// TODO: Обернуть требуемые экраны в SafeArea (проверить на iPhone X)
// TODO: провести эксперимент - (firebase_auth) будет ли работать в offline user.getIdToken(true)?
// TODO: убрать kButtonIconSize - задавать через theme
// TODO: убрать в схеме данных time zone - "timestamp without time zone", использую UTC
// TODO: добавить firebase_remote_config (или ProfileModel?)

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// Streams are created so that app can respond to notification-related events
// since the plugin is initialised in the `main` function
final didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotificationModel>();
final selectNotificationSubject = BehaviorSubject<String>();
NotificationAppLaunchDetails notificationAppLaunchDetails;

var _analytics = FirebaseAnalytics();
FirebaseAnalytics get analytics {
  return _analytics ??= FirebaseAnalytics();
}

final navigatorKey = GlobalKey<NavigatorState>();
NavigatorState get navigator => navigatorKey.currentState;

// TODO: вынести в AppCubit и заменить на hydrated_bloc
PersistedData appState;
// TODO: удалить, когда везде будет через BLoC
GraphQLClient client; // = _createClient();
// TODO: вынести в ProfileCubit
final localDeletedUnitIds = <String>{}; // ie Set()

// don't use async for main!
void main() {
  // timeDilation = 4.0; // Will slow down animations by a factor of two
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
    final initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('app_icon'),
      // Note: permissions aren't requested here just to demonstrate
      // that can be done later using the `requestPermissions()` method
      // of the `IOSFlutterLocalNotificationsPlugin` class
      // final initializationSettingsIOS = ;
      iOS: IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotificationModel(
              id: id, title: title, body: body, payload: payload));
        },
      ),
    );
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
    EquatableConfig.stringify = isInDebugMode;
    // Bloc.observer = SimpleBlocObserver();
    HydratedBloc.storage = await HydratedStorage.build();
    runApp(
      App(
        authenticationRepository: AuthenticationRepository(),
        databaseRepository: DatabaseRepository(),
        remoteConfig: await RemoteConfig.instance,
      ),
    );
  }, (error, stackTrace) {
    out('**** runZonedGuarded ****');
    out('$error');
    out('$stackTrace');
    // TODO: [MVP] отправлять ошибки в Sentry (или Firebase Crashlytics)
    // TODO: [MVP] не перехватывается "NoSuchMethodError: The method '[]' was called on null." при трансформации json
  });
}

class App extends StatelessWidget {
  App({
    Key key,
    @required this.authenticationRepository,
    @required this.databaseRepository,
    @required this.remoteConfig,
  })  : assert(authenticationRepository != null),
        assert(databaseRepository != null),
        assert(remoteConfig != null),
        super(key: key);

  final AuthenticationRepository authenticationRepository;
  final DatabaseRepository databaseRepository;
  final RemoteConfig remoteConfig;

  @override
  Widget build(BuildContext context) {
    Widget result = AppView();
    result = BlocProvider(
      create: (BuildContext context) {
        return ProfileCubit(databaseRepository);
      },
      child: result,
    );
    result = RepositoryProvider.value(
      value: databaseRepository,
      child: result,
    );
    result = BlocProvider(
      create: (BuildContext context) {
        return AuthenticationCubit(authenticationRepository);
      },
      child: result,
    );
    result = RepositoryProvider.value(
      value: authenticationRepository,
      child: result,
    );
    result = BlocProvider.value(
      value: VersionCubit(remoteConfig),
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
      ],
      child: result,
    );
    result = PersistedAppState(
      storage: JsonFileStorage(),
      child: result,
    );
    return result;
  }
}

class AppView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget result;
    final theme = Theme.of(context);
    result = MaterialApp(
      // debugShowCheckedModeBanner: isInDebugMode,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      navigatorObservers: <NavigatorObserver>[
        FirebaseAnalyticsObserver(analytics: analytics),
        BotToastNavigatorObserver(),
      ],
      // locale: isInDebugMode ? DevicePreview.of(context).locale : null,
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
        // analytics.setCurrentScreen(screenName: '/app');
        out('builder');
        return BlocConsumer<VersionCubit, VersionState>(
          listenWhen: (VersionState previous, VersionState current) {
            return previous.supportValue != current.supportValue &&
                !current.isValidPackageValue;
          },
          listener: (BuildContext context, VersionState state) {
            navigator.pushAndRemoveUntil<void>(
              UpdateScreen().getRoute(),
              (Route route) => false,
            );
          },
          buildWhen: (VersionState previous, VersionState current) {
            return previous.supportValue != current.supportValue;
          },
          builder: (BuildContext context, VersionState state) {
            Widget result = child;
            if (state.isValidPackageValue) {
              result = BlocListener<ProfileCubit, ProfileState>(
                listenWhen: (ProfileState previous, ProfileState current) {
                  return previous.status != current.status &&
                      current.status == ProfileStatus.ready;
                },
                listener: (BuildContext context, ProfileState state) {
                  navigator.pushAndRemoveUntil<void>(
                    HomeScreen().getRoute(),
                    (Route route) => false,
                  );
                },
                child: result,
              );
              result = BlocListener<AuthenticationCubit, AuthenticationState>(
                listener: (BuildContext context, AuthenticationState state) {
                  final cases = {
                    AuthenticationStatus.authenticated: () {
                      navigator.pushAndRemoveUntil<void>(
                        LoadProfileScreen().getRoute(),
                        (Route route) => false,
                      );
                    },
                    AuthenticationStatus.unauthenticated: () {
                      navigator.pushAndRemoveUntil<void>(
                        LoginScreen().getRoute(),
                        (Route route) => false,
                      );
                    },
                    AuthenticationStatus.unknown: () {},
                  };
                  assert(cases.length == AuthenticationStatus.values.length);
                  cases[state.status]();
                },
                child: result,
              );
            }
            result = BotToastInit()(context, result);
            result = _MediaQueryWrapper(result);
            return result;
          },
        );
      },
      onGenerateRoute: (RouteSettings settings) => SplashScreen().getRoute(),
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
    result = _LifecycleManager(
      child: result,
    );
    return result;
  }
}

class _MediaQueryWrapper extends StatelessWidget {
  _MediaQueryWrapper(this.child);

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

// code from https://medium.com/flutter-community/build-a-lifecycle-manager-to-manage-your-services-b9c928d3aed7
// https://api.flutter.dev/flutter/widgets/WidgetsBindingObserver-class.html
class _LifecycleManager extends StatefulWidget {
  _LifecycleManager({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  _LifecycleManagerState createState() => _LifecycleManagerState();
}

class _LifecycleManagerState extends State<_LifecycleManager>
    with WidgetsBindingObserver {
  // List<_StoppableService> services = [
  //   locator<_LocationService>(), // locator from GetIt
  // ];

  @override
  void initState() {
    super.initState();
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
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(_onAfterBuild);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final data in HomeShowcase.dataPool) {
      data.dispose();
    }
    HomeShowcase.dataPool = null;
    for (final data in HomeUnderway.dataPool) {
      data.dispose();
    }
    HomeUnderway.dataPool = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // out('lyfecycle state = $state');
    if (state == AppLifecycleState.resumed) {
      load(() => getBloc<VersionCubit>(context).load());
    }
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

  void _onAfterBuild(Duration timeStamp) {
    load(() => getBloc<VersionCubit>(context).load());
  }
}

// abstract class _StoppableService {
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

// class _LocationService extends _StoppableService {
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
