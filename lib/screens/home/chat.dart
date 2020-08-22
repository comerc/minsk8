import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:intl/intl.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:extended_list/extended_list.dart';
import 'package:minsk8/import.dart';

// TODO: Реализовать sticky displayDate как sticky_grouped_list

class HomeChat extends StatefulWidget {
  HomeChat();

  // static final showcaseKey = GlobalKey<ShowcaseState>();
  // static List<ChatData> dataPool;
  static NoticeData sourceList;

  @override
  _HomeChatState createState() => _HomeChatState();
}

class _HomeChatState extends State<HomeChat> {
  @override
  Widget build(BuildContext context) {
    // final child = Showcase(
    //   key: showcaseKey,
    //   tabModels: <UnderwayModel>[
    //     UnderwayModel(UnderwayValue.wish, 'Желаю'),
    //     UnderwayModel(UnderwayValue.want, 'Забираю'),
    //     // UnderwayModel(UnderwayValue.take, 'Забираю'),
    //     // UnderwayModel(UnderwayValue.past, 'Мимо'),
    //     UnderwayModel(UnderwayValue.give, 'Отдаю'),
    //   ],
    //   dataPool: dataPool,
    //   pullToRefreshNotificationKey: pullToRefreshNotificationKey,
    //   poolForReloadTabs: poolForReloadTabs,
    // );
    final child = PullToRefreshNotification(
      onRefresh: _onRefresh,
      maxDragOffset: kMaxDragOffset,
      child: Stack(
        children: <Widget>[
          LoadingMoreCustomScrollView(
            rebuildCustomScrollView: true,
            // in case list is not full screen and remove ios Bouncing
            physics: AlwaysScrollableClampingScrollPhysics(),
            slivers: <Widget>[
              LoadingMoreSliverList(
                SliverListConfig<NoticeItem>(
                  extendedListDelegate: ExtendedListDelegate(
                    collectGarbage: (List<int> garbages) {
                      // garbages.forEach((int index) {
                      //   final unit = HomeChat.sourceList[index].payment?.unit;
                      //   if (unit == null) return;
                      //   final image = unit.images[0];
                      //   final provider = ExtendedNetworkImageProvider(
                      //     image.getDummyUrl(unit.id),
                      //   );
                      //   provider.evict();
                      // });
                    },
                  ),
                  itemBuilder:
                      (BuildContext context, NoticeItem item, int index) {
                    if (item.displayDate != null) {
                      return Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(8),
                        child: Container(
                          child: Text(
                            item.displayDate,
                            style: TextStyle(
                              fontSize: kFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ),
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.all(
                              Radius.circular(kFontSize),
                            ),
                          ),
                        ),
                      );
                    }
                    final notice = item.notice;
                    void Function() action;
                    Widget avatar = CircleAvatar(
                      child: Logo(size: kDefaultIconSize),
                      backgroundColor: Colors.white,
                    );
                    var text = 'no data';
                    final proclamation = item.notice.proclamation;
                    if (proclamation != null) {
                      text = proclamation.text;
                      final unit = proclamation.unit;
                      if (unit != null) {
                        avatar = Avatar(unit.avatarUrl);
                      }
                    }
                    final suggestion = item.notice.suggestion;
                    if (suggestion != null) {
                      text = {
                        QuestionValue.condition:
                            'Укажите состояние и\u00A0работоспособность. Желающие хотят узнать, подходит\u00A0ли им\u00A0лот.',
                        QuestionValue.model:
                            'Укажите модель. Желающие хотят узнать, подходит\u00A0ли им\u00A0лот.',
                        QuestionValue.original:
                            'Укажите, это\u00A0оригинал или\u00A0реплика. Желающие хотят узнать, подходит\u00A0ли им\u00A0лот.',
                        QuestionValue.size:
                            'Укажите размеры. Желающие хотят узнать, подходит\u00A0ли им\u00A0лот.',
                        QuestionValue.time:
                            'Укажите, в\u00A0какое время нужно забирать лот. Желающие хотят узнать, подходит\u00A0ли им\u00A0лот.',
                      }[suggestion.question];
                      final unit = suggestion.unit;
                      avatar = Avatar(unit.avatarUrl);
                    }
                    return Material(
                      child: InkWell(
                        onLongPress:
                            () {}, // чтобы сократить время для splashColor
                        onTap: action,
                        child: ListTile(
                          leading: avatar,
                          title: Text(text),
                          subtitle: Text(
                            DateFormat.jm('ru_RU').format(
                              notice.createdAt.toLocal(),
                            ),
                          ),
                          dense: true,
                        ),
                      ),
                    );
                  },
                  sourceList: HomeChat.sourceList,
                  indicatorBuilder: (
                    BuildContext context,
                    IndicatorStatus status,
                  ) {
                    return buildListIndicator(
                      context: context,
                      status: status,
                      sourceList: HomeChat.sourceList,
                    );
                  },
                  lastChildLayoutType: LastChildLayoutType.foot,
                ),
              ),
            ],
          ),
          PullToRefreshContainer((PullToRefreshScrollNotificationInfo info) {
            final offset = info?.dragOffset ?? 0.0;
            return Positioned(
              top: offset - kToolbarHeight,
              left: 0,
              right: 0,
              child: Center(child: info?.refreshWiget),
            );
          }),
        ],
      ),
    );

    return SafeArea(
      child: child,
      bottom: false,
    );
  }

  Future<bool> _onRefresh() async {
    final sourceList = HomeChat.sourceList;
    final result = await sourceList.handleRefresh();
    if (!result) {
      final snackBar = SnackBar(
          content:
              Text('Не удалось выполнить обновление. Попробуйте ещё раз.'));
      Scaffold.of(context).showSnackBar(snackBar);
    }
    return result;
  }
}

// import 'package:flutter/material.dart';
// import 'package:minsk8/import.dart';

// loading_more_list/example/lib/demo/multiple_sliver_demo.dart

// TODO: [MVP] вместо велосипедирования, прикрутить реализацию чата
// https://uikitty.net/achat-flutter-firebase-chat-template/
// https://pub.dev/packages/firebase_in_app_messaging
// https://pub.dev/packages/dash_chat
// https://gist.github.com/mancj/c298c72320666a58d0682d5ba80b74b6
// https://beltran.work/blog/building-a-messaging-app-in-flutter-part-i-project-structure/
// https://getstream.io/chat/
// https://pub.dev/packages/flutter_chat
// https://github.com/AmitJoki/Enigma

// class HomeChat extends StatelessWidget {
//   // Chat(this.arguments);

//   // final ChatRouteArguments arguments;

//   @override
//   Widget build(BuildContext context) {
//     // тут не надо ScrollBody
//     final child = Center(
//       child: Text('chat'),
//     );
//     return SafeArea(
//       child: child,
//       bottom: false,
//     );
//   }
// }

// class ChatRouteArguments {
//   ChatRouteArguments(this.userId);

//   final int userId;
// }
