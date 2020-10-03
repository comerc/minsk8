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

// TODO: отображать красный кружочек в трёх местах: нижняя иконка, таб "сообщения", иконка лота.

class HomeInterplay extends StatelessWidget {
  HomeInterplay({this.tabIndex});

  static final wrapperKey = GlobalKey<WrapperState>();
  static List<SourceList> dataPool;
  static final pullToRefreshNotificationKey =
      GlobalKey<PullToRefreshNotificationState>();
  static final poolForReloadTabs = <int>{}; // ie Set()

  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    final child = Wrapper(
      key: wrapperKey,
      tabIndex: tabIndex,
      tabModels: <InterplayModel>[
        InterplayModel(InterplayValue.chat, 'Сообщения'),
        InterplayModel(InterplayValue.notice, 'Уведомления'),
      ],
      dataPool: dataPool,
      buildList: (int tabIndex) {
        return [
          ChatList(
            tagPrefix: '${this.tabIndex}-$tabIndex',
            sourceList: dataPool[0] as ChatData,
            // dataPool: dataPool[0] as List<ChatData>,
          ),
          NoticeList(
            tagPrefix: '${this.tabIndex}-$tabIndex',
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
