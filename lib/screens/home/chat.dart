import 'package:flutter/material.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extended;
import 'package:minsk8/import.dart';

// TODO: Реализовать sticky displayDate как sticky_grouped_list

class HomeChat extends StatefulWidget {
  HomeChat();

  // static final showcaseKey = GlobalKey<ShowcaseState>();
  static List<SourceList> dataPool;
  // static NoticeData sourceList;

  @override
  _HomeChatState createState() => _HomeChatState();
}

class _HomeChatState extends State<HomeChat>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int get tabIndex => _tabController.index;

  final tabModels = <InteractionModel>[
    InteractionModel(InteractionValue.chat, 'Сообщения'),
    InteractionModel(InteractionValue.notice, 'Уведомления'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: tabModels.length,
      vsync: this,
    );
    // _tabController.addListener(() {
    //   final sourceList = widget.dataPool[_tabController.index];
    //   if (!_tabController.indexIsChanging) {
    //     // print(
    //     //     'indexIsChanging ${sourceList.isLoadDataByTabChange} ${widget.tabModels[_tabController.index].value}');
    //     // если для категории еще не было загрузки (переходом по tab-у),
    //     // то добавление нового unit-а в /add_unit зря добавит tab в widget.poolForReloadTabs,
    //     // а потому удаление выполняю в любом случае, без оглядки на sourceList.isLoadDataByTabChange
    //     final isContaintsInPool =
    //         widget.poolForReloadTabs.remove(_tabController.index);
    //     if (sourceList.isLoadDataByTabChange) {
    //       if (_tabController.index > 0) {
    //         final sourceListBefore = widget.dataPool[_tabController.index - 1];
    //         sourceListBefore.resetIsLoadDataByTabChange();
    //       }
    //       sourceList.resetIsLoadDataByTabChange();
    //     } else if (isContaintsInPool) {
    //       // print('pullToRefreshNotificationKey');
    //       widget.pullToRefreshNotificationKey.currentState.show();
    //     }
    //   }
    // });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
    // final child = PullToRefreshNotification(
    //   onRefresh: _onRefresh,
    //   maxDragOffset: kMaxDragOffset,
    //   child: Stack(
    //     children: <Widget>[
    //       LoadingMoreCustomScrollView(
    //         rebuildCustomScrollView: true,
    //         // in case list is not full screen and remove ios Bouncing
    //         physics: AlwaysScrollableClampingScrollPhysics(),
    //         slivers: <Widget>[
    //           LoadingMoreSliverList(
    //             SliverListConfig<NoticeItem>(
    //               extendedListDelegate: ExtendedListDelegate(
    //                 collectGarbage: (List<int> garbages) {
    //                   // garbages.forEach((int index) {
    //                   //   final unit = HomeChat.sourceList[index].payment?.unit;
    //                   //   if (unit == null) return;
    //                   //   final image = unit.images[0];
    //                   //   final provider = ExtendedNetworkImageProvider(
    //                   //     image.getDummyUrl(unit.id),
    //                   //   );
    //                   //   provider.evict();
    //                   // });
    //                 },
    //               ),
    //               itemBuilder:
    //                   (BuildContext context, NoticeItem item, int index) {
    //                 if (item.displayDate != null) {
    //                   return Container(
    //                     alignment: Alignment.center,
    //                     padding: EdgeInsets.all(8),
    //                     child: Container(
    //                       child: Text(
    //                         item.displayDate,
    //                         style: TextStyle(
    //                           fontSize: kFontSize,
    //                           fontWeight: FontWeight.w600,
    //                           color: Colors.black.withOpacity(0.8),
    //                         ),
    //                       ),
    //                       padding:
    //                           EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    //                       decoration: BoxDecoration(
    //                         color: Colors.grey[300],
    //                         borderRadius: BorderRadius.all(
    //                           Radius.circular(kFontSize),
    //                         ),
    //                       ),
    //                     ),
    //                   );
    //                 }
    //                 final notice = item.notice;
    //                 void Function() action;
    //                 Widget avatar = CircleAvatar(
    //                   child: Logo(size: kDefaultIconSize),
    //                   backgroundColor: Colors.white,
    //                 );
    //                 var text = 'no data';
    //                 final proclamation = item.notice.proclamation;
    //                 if (proclamation != null) {
    //                   text = proclamation.text;
    //                   final unit = proclamation.unit;
    //                   if (unit != null) {
    //                     avatar = Avatar(unit.avatarUrl);
    //                   }
    //                 }
    //                 final suggestion = item.notice.suggestion;
    //                 if (suggestion != null) {
    //                   text = {
    //                     QuestionValue.condition:
    //                         'Укажите состояние и\u00A0работоспособность. Желающие хотят узнать, подходит\u00A0ли им\u00A0лот.',
    //                     QuestionValue.model:
    //                         'Укажите модель. Желающие хотят узнать, подходит\u00A0ли им\u00A0лот.',
    //                     QuestionValue.original:
    //                         'Укажите, это\u00A0оригинал или\u00A0реплика. Желающие хотят узнать, подходит\u00A0ли им\u00A0лот.',
    //                     QuestionValue.size:
    //                         'Укажите размеры. Желающие хотят узнать, подходит\u00A0ли им\u00A0лот.',
    //                     QuestionValue.time:
    //                         'Укажите, в\u00A0какое время нужно забирать лот. Желающие хотят узнать, подходит\u00A0ли им\u00A0лот.',
    //                   }[suggestion.question];
    //                   final unit = suggestion.unit;
    //                   avatar = Avatar(unit.avatarUrl);
    //                 }
    //                 return Material(
    //                   child: InkWell(
    //                     onLongPress:
    //                         () {}, // чтобы сократить время для splashColor
    //                     onTap: action,
    //                     child: ListTile(
    //                       leading: avatar,
    //                       title: Text(text),
    //                       subtitle: Text(
    //                         DateFormat.jm('ru_RU').format(
    //                           notice.createdAt.toLocal(),
    //                         ),
    //                       ),
    //                       dense: true,
    //                     ),
    //                   ),
    //                 );
    //               },
    //               sourceList: HomeChat.sourceList,
    //               indicatorBuilder: (
    //                 BuildContext context,
    //                 IndicatorStatus status,
    //               ) {
    //                 return buildListIndicator(
    //                   context: context,
    //                   status: status,
    //                   sourceList: HomeChat.sourceList,
    //                 );
    //               },
    //               lastChildLayoutType: LastChildLayoutType.foot,
    //             ),
    //           ),
    //         ],
    //       ),
    //       PullToRefreshContainer((PullToRefreshScrollNotificationInfo info) {
    //         final offset = info?.dragOffset ?? 0.0;
    //         return Positioned(
    //           top: offset - kToolbarHeight,
    //           left: 0,
    //           right: 0,
    //           child: Center(child: info?.refreshWiget),
    //         );
    //       }),
    //     ],
    //   ),
    // );

    final tabBar = TabBar(
      controller: _tabController,
      labelColor: Colors.blue,
      indicatorColor: Colors.blue,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorWeight: 2,
      unselectedLabelColor: Colors.grey,
      isScrollable: true,
      tabs: tabModels
          .map((EnumModel element) => Tab(text: element.name))
          .toList(),
    );
    final tabBarHeight = tabBar.preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final pinnedHeaderHeight =
        // pinned statusBar height
        statusBarHeight +
            // pinned SliverAppBar height in header
            // kToolbarHeight +
            // pinned tabbar height in header
            tabBarHeight;
    final child = extended.NestedScrollView(
      physics: ClampingScrollPhysics(),
      pinnedHeaderSliverHeightBuilder: () => pinnedHeaderHeight,
      innerScrollPositionKeyBuilder: () => Key('${_tabController.index}'),
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => [
        PullToRefreshContainer(
          (PullToRefreshScrollNotificationInfo info) {
            return SliverPersistentHeader(
              pinned: true,
              delegate: CommonSliverPersistentHeaderDelegate(
                builder: (BuildContext context, double shrinkOffset,
                    bool overlapsContent) {
                  return ListTabBar(
                    info: info,
                    shrinkOffset: shrinkOffset,
                    // overlapsContent: overlapsContent,
                    tabBar: tabBar,
                  );
                },
                height: tabBarHeight,
              ),
            );
          },
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: List.generate(
          tabModels.length,
          (int index) {
            if (index == 0) {
              return ShowcaseList(
                tabIndex: 0,
                sourceList: HomeChat.dataPool[0] as ShowcaseData,
              );
            }
            if (index == 1) {
              // return ShowcaseList(
              //   tabIndex: 1,
              //   sourceList: HomeChat.dataPool[1] as ShowcaseData,
              // );
              return NoticeList(
                  tabIndex: 1, sourceList: HomeChat.dataPool[1] as NoticeData);
            }
            return null;
            // return [
            //   ShowcaseList(
            //     tabIndex: 0,
            //     sourceList: HomeChat.dataPool[0] as ShowcaseData,
            //   ),
            //   NoticeList(
            //       tabIndex: 1, sourceList: HomeChat.dataPool[1] as NoticeData)
            // ][index];
          },
        ),
      ),
    );
    final body = PullToRefreshNotification(
      // key: widget.pullToRefreshNotificationKey,
      onRefresh: _onRefresh,
      maxDragOffset: kMaxDragOffset,
      child: child,
    );
    return SafeArea(
      child: body,
      bottom: false,
    );
  }

  Future<bool> _onRefresh() async {
    final sourceList = HomeChat.dataPool[_tabController.index];
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
