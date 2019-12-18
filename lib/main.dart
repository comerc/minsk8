// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:state_persistence/state_persistence.dart';
import 'screens/about.dart';
import 'screens/add_item.dart';
import 'screens/chat.dart';
import 'screens/edit_item.dart';
import 'screens/forgot_password.dart';
import 'screens/home.dart';
import "screens/image_capture.dart";
import "screens/image_pinch.dart";
import 'screens/item.dart';
import 'screens/kinds.dart';
import 'screens/login.dart';
import 'screens/map.dart';
import 'screens/my_items.dart';
import 'screens/notifications.dart';
import 'screens/pay.dart';
import 'screens/profile.dart';
import 'screens/search.dart';
import 'screens/settings.dart';
import 'screens/showcase.dart';
import 'screens/sign_up.dart';
import 'screens/start.dart';
import 'screens/underway.dart';
import 'screens/wish_list.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PersistedAppState(
      storage: JsonFileStorage(),
      child: MaterialApp(
        // debugShowCheckedModeBanner: false,
        title: 'Flutter Map Example',
        // theme: ThemeData(
        //   primarySwatch: mapBoxBlue,
        // ),
        // builder: (BuildContext context, Widget child) {
        //   //If the design is based on the size of the iPhone6 ​​(iPhone6 ​​750*1334)
        //   //If you want to set the font size is scaled according to the system's "font size" assist option
        //   ScreenUtil.instance =
        //       ScreenUtil(width: 300, height: 700, allowFontScaling: true)
        //         ..init(context);
        //   return child;
        // },
        home: HomeScreen(),
        routes: <String, WidgetBuilder>{
          '/about': (context) => AboutScreen(),
          '/add_item': (context) => AddItemScreen(),
          '/chat': (context) => ChatScreen(),
          '/edit_item': (context) => EditItemScreen(),
          '/forgot_password': (context) => ForgotPasswordScreen(),
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
          '/wish_list': (context) => WishListScreen(),
        },
        onGenerateRoute: (settings) {
          print(settings);
          return null;
        },
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
