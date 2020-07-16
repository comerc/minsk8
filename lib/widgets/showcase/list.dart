import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:extended_image_library/extended_image_library.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extended;
import 'package:minsk8/import.dart';

// TODO: (на сервере) при добавлении победителя, включать item.is_winned - для фильтрации витрины
// TODO: кнопка "обновить ленту" - через какое-то время её показывать?

class ShowcaseList extends StatefulWidget {
  ShowcaseList({
    Key key,
    this.tabIndex,
    this.sourceList,
  })  : scrollPositionKey = Key('$tabIndex'),
        super(key: key);

  final Key scrollPositionKey;
  final CommonData sourceList;
  final int tabIndex;

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
    // TODO: проверить на IPad Retina и Samsung Note 12
    return extended.NestedScrollViewInnerScrollPositionKeyWidget(
      widget.scrollPositionKey,
      LoadingMoreCustomScrollView(
        // TODO: не показывать, только когда scroll == 0, чтобы не мешать refreshWiget
        showGlowLeading: false,
        rebuildCustomScrollView: true,
        physics: ClampingScrollPhysics(),
        slivers: [
          LoadingMoreSliverList(SliverListConfig<ItemModel>(
            extendedListDelegate:
                SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              crossAxisCount: getCrossAxisCount(context),
              crossAxisSpacing: 16,
              mainAxisSpacing: 32,
              collectGarbage: (List<int> garbages) {
                garbages.forEach((index) {
                  final item = widget.sourceList[index];
                  final image = item.images[0];
                  final provider = ExtendedNetworkImageProvider(
                    image.getDummyUrl(item.id),
                  );
                  provider.evict();
                });
              },
            ),
            itemBuilder: (BuildContext context, ItemModel item, int index) {
              return ShowcaseItem(
                item: item,
                tabIndex: widget.tabIndex,
                isCover: isSmallWidth,
              );
            },
            sourceList: widget.sourceList,
            indicatorBuilder: _buildIndicator,
            // TODO: https://github.com/fluttercandies/loading_more_list/issues/20
            padding: EdgeInsets.all(16),
            lastChildLayoutType: LastChildLayoutType.foot,
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
        result = Container(height: 0);
        break;
      case IndicatorStatus.loadingMoreBusying:
        result = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              // margin: EdgeInsets.only(right: 5),
              height: 15,
              width: 15,
              child: buildProgressIndicator(context),
            ),
            // Text("正在加载...不要着急")
          ],
        );
        result = _buildBackground(false, result);
        break;
      case IndicatorStatus.fullScreenBusying:
        result = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              // margin: EdgeInsets.only(right: 5),
              height: 30,
              width: 30,
              child: buildProgressIndicator(context),
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
        result = Material(
          child: InkWell(
            onTap: () {
              widget.sourceList.errorRefresh();
            },
            child: result,
          ),
        );
        break;
      case IndicatorStatus.fullScreenError:
        result = Text(
          // "好像出现了问题呢？",
          'Кажется, что-то пошло не так?',
        );
        result = _buildBackground(true, result);
        result = Material(
          child: InkWell(
            onTap: () {
              widget.sourceList.errorRefresh();
            },
            child: result,
          ),
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
}
