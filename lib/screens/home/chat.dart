import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

// TODO: вместо велосипедирования, прикрутить реализацию чата
// https://uikitty.net/achat-flutter-firebase-chat-template/
// https://pub.dev/packages/firebase_in_app_messaging
// https://pub.dev/packages/dash_chat
// https://gist.github.com/mancj/c298c72320666a58d0682d5ba80b74b6
// https://beltran.work/blog/building-a-messaging-app-in-flutter-part-i-project-structure/
// https://getstream.io/chat/
// https://pub.dev/packages/flutter_chat

class HomeChat extends StatelessWidget {
  // Chat(this.arguments);

  // final ChatRouteArguments arguments;

  @override
  Widget build(BuildContext context) {
    // тут не надо ScrollBody
    final child = Center(
      child: Text('chat'),
    );
    return SafeArea(child: child);
  }
}

// class ChatRouteArguments {
//   ChatRouteArguments(this.userId);

//   final int userId;
// }
