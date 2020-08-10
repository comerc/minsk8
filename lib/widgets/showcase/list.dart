import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:extended_image_library/extended_image_library.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extended;
import 'package:minsk8/import.dart';

// TODO: [MVP] (на сервере) при добавлении победителя, включать unit.is_winned - для фильтрации витрины
// TODO: кнопка "обновить ленту" - через какое-то время её показывать?

class ShowcaseList extends StatefulWidget {
  ShowcaseList({
    Key key,
    this.tabIndex,
    this.sourceList,
  })  : scrollPositionKey = Key('$tabIndex'),
        super(key: key);

  final Key scrollPositionKey;
  final SourceList<UnitModel> sourceList;
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
    final width = MediaQuery.of(context).size.width;
    final isSmallWidth = width < kSmallWidth;
    final isMediumWidth = width < kMediumWidth;
    final isLargeWidth = width < kLargeWidth;
    final crossAxisCount =
        isSmallWidth ? 1 : isMediumWidth ? 2 : isLargeWidth ? 3 : 4;
    return extended.NestedScrollViewInnerScrollPositionKeyWidget(
      widget.scrollPositionKey,
      LoadingMoreCustomScrollView(
        // TODO: не показывать, только когда scroll == 0, чтобы не мешать refreshWiget
        showGlowLeading: false,
        rebuildCustomScrollView: true,
        physics: ClampingScrollPhysics(),
        slivers: <Widget>[
          LoadingMoreSliverList(
            SliverListConfig<UnitModel>(
              extendedListDelegate:
                  SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                collectGarbage: (List<int> garbages) {
                  garbages.forEach((int index) {
                    final unit = widget.sourceList[index];
                    final image = unit.images[0];
                    final provider = ExtendedNetworkImageProvider(
                      image.getDummyUrl(unit.id),
                    );
                    provider.evict();
                  });
                },
              ),
              itemBuilder: (BuildContext context, UnitModel unit, int index) {
                return ShowcaseItem(
                  unit: unit,
                  tabIndex: widget.tabIndex,
                  isCover: isSmallWidth,
                );
              },
              sourceList: widget.sourceList,
              indicatorBuilder: (
                BuildContext context,
                IndicatorStatus status,
              ) {
                return buildListIndicator(
                  context: context,
                  status: status,
                  sourceList: widget.sourceList,
                );
              },
              // TODO: https://github.com/fluttercandies/loading_more_list/issues/20
              padding: EdgeInsets.symmetric(horizontal: 16),
              lastChildLayoutType: LastChildLayoutType.foot,
            ),
          ),
        ],
      ),
    );
  }
}
