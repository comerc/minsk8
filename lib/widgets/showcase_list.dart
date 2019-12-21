import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:minsk8/import.dart';
import 'package:extended_image_library/extended_image_library.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extended;

class ShowcaseList extends StatefulWidget {
  final Key scrollPositionKey;
  final TuChongRepository sourceList;

  ShowcaseList(this.scrollPositionKey, this.sourceList);

  @override
  _ShowcaseListState createState() => _ShowcaseListState();
}

class _ShowcaseListState extends State<ShowcaseList>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final headerHeight = 32.0;
    return extended.NestedScrollViewInnerScrollPositionKeyWidget(
      widget.scrollPositionKey,
      LoadingMoreCustomScrollView(
        showGlowLeading: false,
        rebuildCustomScrollView: true,
        physics: ClampingScrollPhysics(),
        slivers: <Widget>[
          SliverPersistentHeader(
              pinned: false,
              floating: false,
              delegate: CommonSliverPersistentHeaderDelegate(
                  Container(
                    alignment: Alignment.center,
                    height: headerHeight,
                    color: Colors.red,
                    child: Text(
                        "This is a single sliver List with no pinned header"),
                    //color: Colors.white,
                  ),
                  headerHeight)),
          LoadingMoreSliverList(SliverListConfig<TuChongItem>(
            itemBuilder: buildItem,
            sourceList: widget.sourceList,
            // isLastOne: false,
            // showGlowLeading: false,
            // showGlowTrailing: false,
            collectGarbage: (List<int> indexes) {
              indexes.forEach((index) {
                final item = widget.sourceList[index];
                if (item.hasImage) {
                  final provider = ExtendedNetworkImageProvider(
                    item.imageUrl,
                  );
                  provider.evict();
                }
              });
            },
          ))
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
