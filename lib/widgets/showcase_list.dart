import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:extended_image_library/extended_image_library.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extended;
import 'package:minsk8/import.dart';

class ShowcaseList extends StatefulWidget {
  final Key scrollPositionKey;
  final ItemsRepository sourceList;

  ShowcaseList({Key key, this.scrollPositionKey, this.sourceList})
      : super(key: key);

  @override
  _ShowcaseListState createState() => _ShowcaseListState();
}

class _ShowcaseListState extends State<ShowcaseList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // final headerHeight = 32.0;
    return extended.NestedScrollViewInnerScrollPositionKeyWidget(
      widget.scrollPositionKey,
      LoadingMoreCustomScrollView(
        showGlowLeading: false,
        rebuildCustomScrollView: true,
        physics: ClampingScrollPhysics(),
        slivers: [
          // SliverPersistentHeader(
          //   pinned: false,
          //   floating: false,
          //   delegate: CommonSliverPersistentHeaderDelegate(
          //     Container(
          //       alignment: Alignment.center,
          //       height: headerHeight,
          //       color: Colors.red,
          //       child:
          //           Text("This is a single sliver List with no pinned header"),
          //       //color: Colors.white,
          //     ),
          //     headerHeight,
          //   ),
          // ),
          LoadingMoreSliverList(SliverListConfig<ItemModel>(
            waterfallFlowDelegate: WaterfallFlowDelegate(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 32,
            ),
            itemBuilder: (BuildContext context, ItemModel item, int index) {
              final tag = '${widget.sourceList.kind}-${item.id}';
              return ShowcaseItem(
                item: item,
                index: index,
                tag: tag,
              );
            },
            sourceList: widget.sourceList,
            indicatorBuilder: _buildIndicator,
            // isLastOne: false,
            // showGlowLeading: false,
            // showGlowTrailing: false,
            padding: EdgeInsets.all(16),
            lastChildLayoutType: LastChildLayoutType.foot,
            collectGarbage: (List<int> indexes) {
              indexes.forEach((index) {
                final item = widget.sourceList[index];
                final image = item.images[0];
                final provider = ExtendedNetworkImageProvider(
                  image.getDummyUrl(item.id),
                );
                provider.evict();
              });
            },
          ))
        ],
      ),
    );
  }

  //you can use IndicatorWidget or build yourself widget
  //in this demo, we define all status.
  Widget _buildIndicator(BuildContext context, IndicatorStatus status) {
    //if your list is sliver list ,you should build sliver indicator for it
    //isSliver=true, when use it in sliver list
    bool isSliver = true;
    Widget result;
    switch (status) {
      case IndicatorStatus.none:
        result = Container(height: 0.0);
        break;
      case IndicatorStatus.loadingMoreBusying:
        result = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              // margin: EdgeInsets.only(right: 5.0),
              height: 15.0,
              width: 15.0,
              child: _getIndicator(context),
            ),
            // Text("正在加载...不要着急")
          ],
        );
        result = _buildBackground(false, result);
        break;
      case IndicatorStatus.fullScreenBusying:
        result = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              // margin: EdgeInsets.only(right: 5.0),
              height: 30.0,
              width: 30.0,
              child: _getIndicator(context),
            ),
            // Text("正在加载...不要着急")
          ],
        );
        result = _buildBackground(true, result);
        if (isSliver) {
          result = SliverFillRemaining(
            child: result,
          );
        } else {
          result = CustomScrollView(
            slivers: [
              SliverFillRemaining(
                child: result,
              )
            ],
          );
        }
        break;
      case IndicatorStatus.error:
        result = Text(
          // "好像出现了问题呢？",
          'Кажется, что-то пошло не так?',
        );
        result = _buildBackground(false, result);
        // TODO: заменить на InkWell, как в Queries.getProfile
        result = GestureDetector(
          onTap: () {
            widget.sourceList.errorRefresh();
          },
          child: result,
        );
        break;
      case IndicatorStatus.fullScreenError:
        result = Text(
          // "好像出现了问题呢？",
          'Кажется, что-то пошло не так?',
        );
        result = _buildBackground(true, result);
        // TODO: заменить на InkWell, как в Queries.getProfile
        result = GestureDetector(
          onTap: () {
            widget.sourceList.errorRefresh();
          },
          child: result,
        );
        if (isSliver) {
          result = SliverFillRemaining(
            child: result,
          );
        } else {
          result = CustomScrollView(
            slivers: [
              SliverFillRemaining(
                child: result,
              )
            ],
          );
        }
        break;
      case IndicatorStatus.noMoreLoad:
        // result = Text("没有更多的了。。不要拖了");
        result = Container();
        result = _buildBackground(false, result);
        break;
      case IndicatorStatus.empty:
        // result = EmptyWidget("这里是空气！");
        result = Text('Нет данных');
        result = _buildBackground(true, result);
        if (isSliver) {
          result = SliverFillRemaining(
            // SliverToBoxAdapter( // заменил
            child: result,
          );
        } else {
          result = CustomScrollView(
            slivers: [
              SliverFillRemaining(
                child: result,
              )
            ],
          );
        }
        break;
    }
    return result;
  }

  Widget _buildBackground(bool full, Widget child) {
    return Container(
        width: double.infinity,
        height: full ? double.infinity : kNavigationBarHeight * 2,
        child: child,
        color: Colors.transparent,
        alignment: full ? Alignment.center : Alignment.topCenter);
  }

  Widget _getIndicator(BuildContext context) {
    return Platform.isIOS
        ? CupertinoActivityIndicator(
            animating: true,
            radius: 16.0,
          )
        : CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
          );
  }
}
