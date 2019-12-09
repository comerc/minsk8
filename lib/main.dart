// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';

import './screens/home.dart';

void main() async {
  // Create Persistor
  final persistor = Persistor<AppState>(
    storage: FlutterStorage(),
    serializer: JsonSerializer<AppState>(AppState.fromJson),
  );

  // Load initial state
  final initialState = await persistor.load();

  final store = Store<AppState>(
    reducer,
    initialState: initialState ?? AppState(),
    middleware: [persistor.createMiddleware()],
  );

  runApp(App(store: store));
}

// Redux
class AppState {
  final int counter;

  AppState({this.counter = 10});

  AppState copyWith({int counter}) =>
      AppState(counter: counter ?? this.counter);

  static AppState fromJson(dynamic json) {
    print('json $json');
    if (json == null) {
      return AppState();
    }
    return AppState(counter: json["counter"] as int);
  }

  dynamic toJson() => {'counter': counter};
}

class IncrementCounterAction {}

class SaveNewerAskAgainAction {
  final bool value;

  SaveNewerAskAgainAction(this.value);
}

AppState reducer(AppState state, Object action) {
  if (action is IncrementCounterAction) {
    // Increment
    return state.copyWith(counter: state.counter + 1);
  }
  // if (action is SaveNewerAskAgainAction) {
  //   // return state.copyWith(counter: state.counter + 1);
  //   return state;
  // }

  return state;
}

class App extends StatelessWidget {
  final Store<AppState> store;

  const App({Key key, this.store}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: MaterialApp(
        // debugShowCheckedModeBanner: false,
        title: 'Flutter Map Example',
        // theme: ThemeData(
        //   primarySwatch: mapBoxBlue,
        // ),
        home: Home(),
        // routes: <String, WidgetBuilder>{
        //   TapToAddPage.route: (context) => TapToAddPage(),
        //   EsriPage.route: (context) => EsriPage(),
        //   PolylinePage.route: (context) => PolylinePage(),
        //   MapControllerPage.route: (context) => MapControllerPage(),
        //   AnimatedMapControllerPage.route: (context) =>
        //       AnimatedMapControllerPage(),
        //   MarkerAnchorPage.route: (context) => MarkerAnchorPage(),
        //   PluginPage.route: (context) => PluginPage(),
        //   PluginScaleBar.route: (context) => PluginScaleBar(),
        //   OfflineMapPage.route: (context) => OfflineMapPage(),
        //   OfflineMBTilesMapPage.route: (context) => OfflineMBTilesMapPage(),
        //   OnTapPage.route: (context) => OnTapPage(),
        //   MovingMarkersPage.route: (context) => MovingMarkersPage(),
        //   CirclePage.route: (context) => CirclePage(),
        //   OverlayImagePage.route: (context) => OverlayImagePage(),
        // },
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
