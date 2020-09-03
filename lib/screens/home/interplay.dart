import 'package:flutter/material.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:minsk8/import.dart';

// TODO: [MVP] вместо велосипедирования, прикрутить реализацию чата
// https://uikitty.net/achat-flutter-firebase-chat-template/
// https://pub.dev/packages/firebase_in_app_messaging
// https://pub.dev/packages/dash_chat
// https://gist.github.com/mancj/c298c72320666a58d0682d5ba80b74b6
// https://beltran.work/blog/building-a-messaging-app-in-flutter-part-i-project-structure/
// https://getstream.io/chat/
// https://pub.dev/packages/flutter_chat
// https://github.com/AmitJoki/Enigma

class HomeInterplay extends StatelessWidget {
  static final wrapperKey = GlobalKey<WrapperState>();
  static List<dynamic> dataPool;
  static final pullToRefreshNotificationKey =
      GlobalKey<PullToRefreshNotificationState>();
  static final poolForReloadTabs = <int>{}; // ie Set()

  @override
  Widget build(BuildContext context) {
    final child = Wrapper(
      key: wrapperKey,
      tabModels: <InterplayModel>[
        InterplayModel(InterplayValue.chat, 'Сообщения'),
        InterplayModel(InterplayValue.notice, 'Уведомления'),
      ],
      dataPool: dataPool,
      buildList: (int tabIndex) {
        return [
          ChatList(
            tabIndex: tabIndex,
            dataPool: dataPool[0] as List<ChatData>,
          ),
          NoticeList(
            tabIndex: tabIndex,
            sourceList: dataPool[1] as NoticeData,
          ),
        ][tabIndex];
      },
      pullToRefreshNotificationKey: pullToRefreshNotificationKey,
      poolForReloadTabs: poolForReloadTabs,
    );
    return SafeArea(
      child: child,
      bottom: false,
    );
  }
}
