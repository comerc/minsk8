import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:extended_image/extended_image.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extended;
import 'package:minsk8/import.dart';

// TODO: Реализовать displayDate как sticky_grouped_list

class NoticeList extends StatefulWidget {
  NoticeList({
    Key key,
    this.tabIndex,
    this.sourceList,
  })  : scrollPositionKey = Key('$tabIndex'),
        super(key: key);

  final Key scrollPositionKey;
  final NoticeData sourceList;
  final int tabIndex;

  @override
  _NoticeListState createState() => _NoticeListState();
}

class _NoticeListState extends State<NoticeList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return extended.NestedScrollViewInnerScrollPositionKeyWidget(
      widget.scrollPositionKey,
      LoadingMoreCustomScrollView(
        // TODO: не показывать, только когда scroll == 0, чтобы не мешать refreshWiget
        showGlowLeading: false,
        rebuildCustomScrollView: true,
        // in case list is not full screen and remove ios Bouncing
        physics: AlwaysScrollableClampingScrollPhysics(),
        slivers: <Widget>[
          LoadingMoreSliverList(
            SliverListConfig<NoticeItem>(
              sourceList: widget.sourceList,
              extendedListDelegate: ExtendedListDelegate(
                collectGarbage: (List<int> garbages) {
                  garbages.forEach((int index) {
                    final noticeItem = widget.sourceList[index];
                    final notice = noticeItem.notice;
                    if (notice == null) return;
                    final unit = notice.proclamation == null
                        ? notice.suggestion.unit // always exists
                        : notice.proclamation.unit;
                    if (unit == null) return;
                    final image = unit.images[0];
                    final provider = ExtendedNetworkImageProvider(
                      image.getDummyUrl(unit.id),
                    );
                    provider.evict();
                  });
                },
              ),
              itemBuilder: (BuildContext context, NoticeItem item, int index) {
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
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: ShapeDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        shape: StadiumBorder(),
                      ),
                    ),
                  );
                }
                final notice = item.notice;
                void Function() action; // TODO: [MVP] реализовать
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
                    onLongPress: () {}, // чтобы сократить время для splashColor
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
              indicatorBuilder: (
                BuildContext context,
                IndicatorStatus status,
              ) {
                return buildListIndicator(
                  context: context,
                  status: status,
                  // TODO: при выполнении handleRefresh не показывать IndicatorStatus.loadingMoreBusying
                  // status: IndicatorStatus.loadingMoreBusying == status
                  //     ? IndicatorStatus.none
                  //     : status,
                  sourceList: widget.sourceList,
                  isSliver: true,
                );
              },
              // lastChildLayoutType: LastChildLayoutType.foot,
            ),
          ),
        ],
      ),
    );
  }
}
