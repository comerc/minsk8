import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:intl/intl.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extended;
import 'package:minsk8/import.dart';

class ChatList extends StatefulWidget {
  ChatList({
    Key key,
    this.tabIndex,
    this.sourceList,
  })  : scrollPositionKey = Key('$tabIndex'),
        super(key: key);

  final Key scrollPositionKey;
  final ChatData sourceList;
  final int tabIndex;

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList>
    with AutomaticKeepAliveClientMixin {
  Future<bool> _future;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.sourceList.rebuild.listen((LoadingMoreBase<ChatModel> data) {
      if (mounted) {
        setState(() {});
      }
    });
    _future = widget.sourceList.refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<bool>(
      // https://github.com/flutter/flutter/issues/11426#issuecomment-414047398
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return buildListIndicator(
            context: context,
            status: IndicatorStatus.fullScreenBusying,
            sourceList: widget.sourceList,
          );
        }
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data) {
          return buildListIndicator(
            context: context,
            status: IndicatorStatus.fullScreenError,
            sourceList: widget.sourceList,
          );
        }
        final items = _normalizeItems();
        return extended.NestedScrollViewInnerScrollPositionKeyWidget(
          widget.scrollPositionKey,
          LoadingMoreCustomScrollView(
            // TODO: не показывать, только когда scroll == 0, чтобы не мешать refreshWiget
            showGlowLeading: false,
            rebuildCustomScrollView: true,
            // in case list is not full screen and remove ios Bouncing
            physics: AlwaysScrollableClampingScrollPhysics(),
            slivers: <Widget>[
              // SliverToBoxAdapter(
              //   child: MySuperButton(),
              // ),
              ...items.keys.map(
                (key) => _ChatListGroup(
                  items: items[key],
                  stage: key,
                  isLast: items.keys.last == key,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: kNavigationBarHeight * 1.5 + 8),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<StageValue, List<ChatModel>> _normalizeItems() {
    final map = <StageValue, List<ChatModel>>{};
    for (final key in StageValue.values) {
      map[key] = [];
    }
    for (final item in widget.sourceList) {
      map[item.stage].add(item);
    }
    final result = <StageValue, List<ChatModel>>{};
    for (final key in StageValue.values) {
      if (map[key].isNotEmpty) {
        result[key] = map[key];
      }
    }
    return result;
  }

  // List<Widget> _buildChat(StageValue stage) {
  //   print(stage.index);
  //   final sourceList = widget.dataPool[stage.index];
  //   return [
  //     _ChatHeader(stage: stage, onChanged: _onChanged),
  //     if (appState['$stage'] == true)
  //       LoadingMoreSliverList(
  //         SliverListConfig<ChatModel>(
  //           sourceList: sourceList,
  //           extendedListDelegate: ExtendedListDelegate(
  //             collectGarbage: (List<int> garbages) {
  //               garbages.forEach((int index) {
  //                 final chat = sourceList[index];
  //                 final unit = chat.unit;
  //                 final image = unit.images[0];
  //                 final provider = ExtendedNetworkImageProvider(
  //                   image.getDummyUrl(unit.id),
  //                 );
  //                 provider.evict();
  //               });
  //             },
  //           ),
  //           itemBuilder: (BuildContext context, ChatModel item, int index) {
  //             final messageText = item.messages.isEmpty
  //                 ? kStages[item.stage.index].text
  //                 : item.messages.last.text;
  //             return Material(
  //               child: InkWell(
  //                 onLongPress: () {}, // чтобы сократить время для splashColor
  //                 onTap: _onTap,
  //                 child: Column(children: <Widget>[
  //                   ListTile(
  //                     leading: Avatar(item.unit.avatarUrl),
  //                     title: Text(item.unit.text),
  //                     subtitle: Text(messageText),
  //                     trailing: Text(
  //                       // TODO: сокращает "июл.", что выглядит странно
  //                       DateFormat.MMMd('ru_RU').format(
  //                         item.updatedAt.toLocal(),
  //                       ),
  //                     ),
  //                     dense: true,
  //                   ),
  //                   Divider(height: 1),
  //                 ]),
  //               ),
  //             );
  //           },
  //           indicatorBuilder: (
  //             BuildContext context,
  //             IndicatorStatus status,
  //           ) {
  //             if (IndicatorStatus.fullScreenBusying == status) {
  //               return SliverToBoxAdapter(
  //                 child: Center(
  //                   child: Container(
  //                     margin: const EdgeInsets.symmetric(vertical: 5),
  //                     height: 15,
  //                     width: 15,
  //                     child: buildProgressIndicator(context),
  //                   ),
  //                 ),
  //               );
  //             }
  //             return Container();
  //           },
  //           lastChildLayoutType: LastChildLayoutType.none,
  //         ),
  //       ),
  //   ];
  // }

  // void _onChanged() {
  //   setState(() {});
  // }

  // void _onTap() {}
}

class _ChatListGroup extends StatefulWidget {
  const _ChatListGroup({
    Key key,
    this.items,
    this.stage,
    this.isLast,
  }) : super(key: key);

  final List<ChatModel> items;
  final StageValue stage;
  final bool isLast;

  @override
  _ChatListGroupState createState() => _ChatListGroupState();
}

class _ChatListGroupState extends State<_ChatListGroup>
    with TickerProviderStateMixin {
  AnimationController _controller;
  bool _isInitialExpanded;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _isInitialExpanded = appState['${widget.stage}'] == true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // timeDilation = 10.0; // 1.0 is normal animation speed.
    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.white,
            child: InkWell(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      child: Text({
                        StageValue.ready: 'Договоритесь о встрече',
                        StageValue.cancel: 'Отменённые',
                        StageValue.success: 'Завершённые',
                      }[widget.stage]),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Row(
                        children: [
                          SizedBox(width: 4),
                          Text('${widget.items.length}'),
                          _AnimatedIcon(
                            controller: _isInitialExpanded
                                ? ReverseAnimation(_controller.view)
                                : _controller.view,
                            child: Icon(
                              Icons.expand_more,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      decoration: ShapeDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        shape: StadiumBorder(),
                      ),
                    )
                  ],
                ),
              ),
              onLongPress: () {}, // чтобы сократить время для splashColor
              onTap: () {
                final isExpanded = appState['${widget.stage}'] == true;
                appState['${widget.stage}'] = !isExpanded;
                if (isExpanded) {
                  _isInitialExpanded
                      ? _controller.forward()
                      : _controller.reverse();
                } else {
                  _isInitialExpanded
                      ? _controller.reverse()
                      : _controller.forward();
                }
              },
            ),
          ),
          _AnimatedBox(
            controller: _isInitialExpanded
                ? ReverseAnimation(_controller.view)
                : _controller.view,
            // TODO: нужен отдельный скролируемый список - архив неактуальных элементов,
            // иначе будет тормозить,
            // т.к. ListBox.itemBuilder создаёт все элементы сразу, в отличии от ListView
            // TODO: реализовать пейджинг для ChatModel, сейчас запрос отдаёт данные безлимитно
            child: ListBox(
              itemCount: widget.items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = widget.items[index];
                final messageText = item.messages.isEmpty
                    ? kStages[item.stage.index].text
                    : item.messages.last.text;
                return Material(
                  child: InkWell(
                    onLongPress: () {}, // чтобы сократить время для splashColor
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/messages',
                        arguments: MessagesRouteArguments(
                          chat: item,
                        ),
                      );
                    },
                    child: Column(children: <Widget>[
                      ListTile(
                        leading: Avatar(item.unit.avatarUrl),
                        title: Text(item.unit.text),
                        subtitle: Text(messageText),
                        trailing: Text(
                          // TODO: сокращает "июл.", что выглядит странно
                          DateFormat.MMMd('ru_RU').format(
                            item.updatedAt.toLocal(),
                          ),
                        ),
                        dense: true,
                      ),
                      if (!(widget.isLast && widget.items.last == item))
                        Divider(height: 1),
                    ]),
                  ),
                );
              },
              // itemBuilder: (BuildContext context, int index) {
              //   return Container(
              //     height: 100,
              //     alignment: Alignment.center,
              //     child: Text('list item $index'),
              //     decoration: BoxDecoration(
              //       color: Colors.lightBlue[100 * (index % 9)],
              //       border: Border(
              //         bottom: BorderSide(color: Theme.of(context).dividerColor),
              //       ),
              //     ),
              //   );
              // },
              separatorBuilder: (BuildContext context, int index) {
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedIcon extends StatelessWidget {
  _AnimatedIcon({
    Key key,
    Animation<double> controller,
    this.child,
  })  : turns = Tween<double>(
          begin: 0.0,
          end: -.5,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.0,
              0.5,
              curve: Curves.ease,
            ),
          ),
        ),
        super(key: key);

  final Animation<double> turns;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: turns,
      child: child,
    );
  }
}

class _AnimatedBox extends StatelessWidget {
  _AnimatedBox({
    Key key,
    this.controller,
    this.child,
  })  :
        // Each animation defined here transforms its value during the subset
        // of the controller's duration defined by the animation's interval.
        // For example the opacity animation transforms its value during
        // the first 10% of the controller's duration.
        heightFactor = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.5,
              0.5,
            ),
          ),
        ),
        opacity = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.5,
              1.0,
              curve: Curves.ease,
            ),
          ),
        ),
        super(key: key);

  final Animation<double> controller;
  final Animation<double> opacity;
  final Animation<double> heightFactor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildAnimation,
      animation: controller,
      child: child,
    );
  }

  // This function is called each time the controller "ticks" a new frame.
  // When it runs, all of the animation's values will have been
  // updated to reflect the controller's current value.
  Widget _buildAnimation(BuildContext context, Widget child) {
    return Opacity(
      opacity: opacity.value,
      child: ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: heightFactor.value,
          child: child,
        ),
      ),
    );
  }
}

// пример применения AutomaticKeepAliveClientMixin для табов
// class MySuperButton extends StatefulWidget {
//   @override
//   _MySuperButtonState createState() => _MySuperButtonState();
// }

// class _MySuperButtonState extends State<MySuperButton>
//     with AutomaticKeepAliveClientMixin {
//   int _value = 0;

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return RaisedButton(
//       child: Text('$_value'),
//       onPressed: () {
//         setState(() {
//           _value = _value + 1;
//         });
//       },
//     );
//   }
// }

// class _ChatHeader extends StatefulWidget {
//   _ChatHeader({
//     Key key,
//     this.stage,
//     this.onChanged,
//   }) : super(key: key);

//   final StageValue stage;
//   final Function onChanged;

//   @override
//   _ChatHeaderState createState() => _ChatHeaderState();
// }

// class _ChatHeaderState extends State<_ChatHeader>
//     with TickerProviderStateMixin {
//   AnimationController _controller;
//   bool _isInitialExpanded;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );
//     _isInitialExpanded = appState['${widget.stage}'] == true;
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // timeDilation = 10.0; // 1.0 is normal animation speed.
//     return SliverToBoxAdapter(
//       child: Material(
//         color: Colors.white,
//         child: InkWell(
//           child: Container(
//             decoration: BoxDecoration(
//               border: Border(
//                 bottom: BorderSide(color: Theme.of(context).dividerColor),
//               ),
//             ),
//             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(
//               children: [
//                 Container(
//                   child: Text(kStages[widget.stage.index].name),
//                 ),
//                 Spacer(),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 2),
//                   child: Row(
//                     children: [
//                       SizedBox(width: 4),
//                       Text('12'),
//                       _AnimatedIcon(
//                         controller: _isInitialExpanded
//                             ? ReverseAnimation(_controller.view)
//                             : _controller.view,
//                         child: Icon(
//                           Icons.expand_more,
//                           size: 20,
//                         ),
//                       ),
//                     ],
//                   ),
//                   decoration: ShapeDecoration(
//                     color: Colors.grey.withOpacity(0.3),
//                     shape: StadiumBorder(),
//                   ),
//                 )
//               ],
//             ),
//           ),
//           onLongPress: () {}, // чтобы сократить время для splashColor
//           onTap: () {
//             final isExpanded = appState['${widget.stage}'] == true;
//             appState['${widget.stage}'] = !isExpanded;
//             widget.onChanged();
//             if (isExpanded) {
//               _isInitialExpanded
//                   ? _controller.forward()
//                   : _controller.reverse();
//             } else {
//               _isInitialExpanded
//                   ? _controller.reverse()
//                   : _controller.forward();
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
