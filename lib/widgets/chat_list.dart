import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:extended_image/extended_image.dart';
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
  final NoticeData sourceList;
  final int tabIndex;

  @override
  ChatState createState() => ChatState();
}

class ChatState extends State<ChatList> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // final headerHeight = 32.0;
    return extended.NestedScrollViewInnerScrollPositionKeyWidget(
      widget.scrollPositionKey,
      LoadingMoreCustomScrollView(
        // TODO: не показывать, только когда scroll == 0, чтобы не мешать refreshWiget
        showGlowLeading: false,
        rebuildCustomScrollView: true,
        // in case list is not full screen and remove ios Bouncing
        physics: AlwaysScrollableClampingScrollPhysics(),
        slivers: <Widget>[
          _ChatListGroup(value: _ChatListGroupValue.ready),
          _ChatListGroup(value: _ChatListGroupValue.cancel),
          SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
          // SliverToBoxAdapter(
          //   child: Material(
          //     color: Colors.white,
          //     child: InkWell(
          //       child: Container(
          //         decoration: BoxDecoration(
          //           border: Border(
          //             bottom: BorderSide(color: Theme.of(context).dividerColor),
          //           ),
          //         ),
          //         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //         child: Row(
          //           children: [
          //             Container(
          //               child: Text('Отменённые'),
          //             ),
          //             Spacer(),
          //             Container(
          //               padding: EdgeInsets.symmetric(horizontal: 2),
          //               child: Row(
          //                 children: [
          //                   SizedBox(width: 4),
          //                   Text('12'),
          //                   Icon(
          //                     _isExpand ? Icons.expand_less : Icons.expand_more,
          //                     size: 20,
          //                   )
          //                 ],
          //               ),
          //               decoration: ShapeDecoration(
          //                 color: Colors.grey.withOpacity(0.3),
          //                 shape: StadiumBorder(),
          //               ),
          //             )
          //           ],
          //         ),
          //       ),
          //       onLongPress: () {}, // чтобы сократить время для splashColor
          //       onTap: () {
          //         setState(() {
          //           _isExpand = !_isExpand;
          //         });
          //       },
          //     ),
          //   ),
          // ),
          // if (_isExpand)
          //   SliverList(
          //     // itemExtent: 50.0,
          //     delegate: SliverChildBuilderDelegate(
          //       (BuildContext context, int index) {
          //         return Container(
          //           height: 100,
          //           alignment: Alignment.center,
          //           color: Colors.lightBlue[100 * (index % 9)],
          //           child: Text('list item $index'),
          //         );
          //       },
          //       childCount: 20,
          //     ),
          //   ),
          // SliverList(delegate: ,)
          // LoadingMoreSliverList(
          //   SliverListConfig<NoticeItem>(
          //     sourceList: widget.sourceList,
          //     extendedListDelegate: ExtendedListDelegate(
          //       collectGarbage: (List<int> garbages) {
          //         garbages.forEach((int index) {
          //           final noticeItem = widget.sourceList[index];
          //           final notice = noticeItem.notice;
          //           if (notice == null) return;
          //           final unit = notice.proclamation == null
          //               ? notice.suggestion.unit // always exists
          //               : notice.proclamation.unit;
          //           if (unit == null) return;
          //           final image = unit.images[0];
          //           final provider = ExtendedNetworkImageProvider(
          //             image.getDummyUrl(unit.id),
          //           );
          //           provider.evict();
          //         });
          //       },
          //     ),
          //     itemBuilder: (BuildContext context, NoticeItem item, int index) {
          //       if (item.displayDate != null) {
          //         return Container(
          //           alignment: Alignment.center,
          //           padding: EdgeInsets.all(8),
          //           child: Container(
          //             child: Text(
          //               item.displayDate,
          //               style: TextStyle(
          //                 fontSize: kFontSize,
          //                 fontWeight: FontWeight.w600,
          //                 color: Colors.black.withOpacity(0.8),
          //               ),
          //             ),
          //             padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          //           ),
          //         );
          //       }
          //       final notice = item.notice;
          //       void Function() action; // TODO: [MVP] реализовать
          //       Widget avatar = CircleAvatar(
          //         child: Logo(size: kDefaultIconSize),
          //         backgroundColor: Colors.white,
          //       );
          //       var text = 'no data';
          //       final proclamation = item.notice.proclamation;
          //       if (proclamation != null) {
          //         text = proclamation.text;
          //         final unit = proclamation.unit;
          //         if (unit != null) {
          //           avatar = Avatar(unit.avatarUrl);
          //         }
          //       }
          //       final suggestion = item.notice.suggestion;
          //       if (suggestion != null) {
          //         text = {
          //           QuestionValue.condition:
          //               'Укажите состояние и\u00A0работоспособность. Желающие хотят узнать, подходит\u00A0ли им\u00A0лот.',
          //           QuestionValue.model:
          //               'Укажите модель. Желающие хотят узнать, подходит\u00A0ли им\u00A0лот.',
          //           QuestionValue.original:
          //               'Укажите, это\u00A0оригинал или\u00A0реплика. Желающие хотят узнать, подходит\u00A0ли им\u00A0лот.',
          //           QuestionValue.size:
          //               'Укажите размеры. Желающие хотят узнать, подходит\u00A0ли им\u00A0лот.',
          //           QuestionValue.time:
          //               'Укажите, в\u00A0какое время нужно забирать лот. Желающие хотят узнать, подходит\u00A0ли им\u00A0лот.',
          //         }[suggestion.question];
          //         final unit = suggestion.unit;
          //         avatar = Avatar(unit.avatarUrl);
          //       }
          //       return Material(
          //         child: InkWell(
          //           onLongPress: () {}, // чтобы сократить время для splashColor
          //           onTap: action,
          //           child: ListTile(
          //             leading: avatar,
          //             title: Text(text),
          //             subtitle: Text(
          //               DateFormat.jm('ru_RU').format(
          //                 notice.createdAt.toLocal(),
          //               ),
          //             ),
          //             dense: true,
          //           ),
          //         ),
          //       );
          //     },
          //     indicatorBuilder: (
          //       BuildContext context,
          //       IndicatorStatus status,
          //     ) {
          //       return buildListIndicator(
          //         context: context,
          //         status: IndicatorStatus.loadingMoreBusying == status
          //             ? IndicatorStatus.none
          //             : status,
          //         sourceList: widget.sourceList,
          //       );
          //     },
          //     // lastChildLayoutType: LastChildLayoutType.foot,
          //   ),
          // ),
        ],
      ),
    );
  }
}

enum _ChatListGroupValue { ready, cancel }

class _ChatListGroup extends StatefulWidget {
  const _ChatListGroup({
    Key key,
    this.value,
  }) : super(key: key);

  final _ChatListGroupValue value;

  @override
  _ChatListGroupState createState() => _ChatListGroupState();
}

class _ChatListGroupState extends State<_ChatListGroup>
    with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Future<void> _playAnimation() async {
  //   try {
  //     await _controller.forward().orCancel;
  //     await _controller.reverse().orCancel;
  //   } on TickerCanceled {
  //     // the animation got canceled, probably because we were disposed
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // timeDilation = 10.0; // 1.0 is normal animation speed.
    final isExpanded = appState['${widget.value}'] == true;
    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Container(
          //   child: SliverList(
          //     // itemExtent: 50.0,
          //     delegate: SliverChildBuilderDelegate(
          //       (BuildContext context, int index) {
          //         return Container(
          //           height: 100,
          //           alignment: Alignment.center,
          //           color: Colors.lightBlue[100 * (index % 9)],
          //           child: Text('list item $index'),
          //         );
          //       },
          //       childCount: 20,
          //     ),
          //   ),
          // ),
          // GestureDetector(
          //   behavior: HitTestBehavior.opaque,
          //   onTap: () {
          //     _playAnimation();
          //   },
          //   child: Center(
          //     child: Container(
          //       width: 300.0,
          //       height: 300.0,
          //       decoration: BoxDecoration(
          //         color: Colors.black.withOpacity(0.1),
          //         border: Border.all(
          //           color: Colors.black.withOpacity(0.5),
          //         ),
          //       ),
          //       child: StaggerAnimation(controller: _controller.view),
          //     ),
          //   ),
          // ),
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
                        _ChatListGroupValue.ready: 'Договоритесь о встрече',
                        _ChatListGroupValue.cancel: 'Отменённые',
                      }[widget.value]),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Row(
                        children: [
                          SizedBox(width: 4),
                          Text('12'),
                          _AnimatedIcon(
                            controller: _controller.view,
                            child: Icon(
                              Icons.expand_more,
                              size: 20,
                            ),
                          ),
                          // Icon(
                          //   isExpanded ? Icons.expand_less : Icons.expand_more,
                          //   size: 20,
                          // )
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
                appState['${widget.value}'] = !isExpanded;
                if (isExpanded) {
                  _controller.reverse();
                } else {
                  _controller.forward();
                }
                setState(() {});
              },
            ),
          ),
          _AnimatedBox(
            controller: _controller.view,
            child: ListBox(
              itemCount: 10,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: Text('list item $index'),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[100 * (index % 9)],
                    border: Border(
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox.shrink();
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
              0.0,
              0.5,
              curve: Curves.ease,
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
          heightFactor: heightFactor.value < 1 ? 0 : 1, // hack for visible
          child: child,
        ),
      ),
    );
  }
}
