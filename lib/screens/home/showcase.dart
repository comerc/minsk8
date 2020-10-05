import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:flutter/cupertino.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:extended_image_library/extended_image_library.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extended;
import 'package:minsk8/import.dart';

class HomeShowcase extends StatelessWidget {
  HomeShowcase({this.tabIndex});

  static final wrapperKey = GlobalKey<WrapperState>();
  static List<ShowcaseData> dataPool;
  static final pullToRefreshNotificationKey =
      GlobalKey<PullToRefreshNotificationState>();
  static final poolForReloadTabs = <int>{}; // ie Set()

  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    final child = Wrapper(
      key: wrapperKey,
      tabIndex: tabIndex,
      tabModels: kAllKinds,
      dataPool: dataPool,
      buildList: (int tabIndex) {
        return ShowcaseList(
          tagPrefix: '${this.tabIndex}-$tabIndex',
          sourceList: dataPool[tabIndex],
        );
      },
      pullToRefreshNotificationKey: pullToRefreshNotificationKey,
      poolForReloadTabs: poolForReloadTabs,
      hasAppBar: true,
    );
    return SafeArea(
      child: child,
      bottom: false,
    );
  }
}

// TODO: [MVP] (на сервере) при добавлении победителя, включать unit.is_winned - для фильтрации витрины
// TODO: кнопка "обновить ленту" - через какое-то время её показывать?
// TODO: применить cacheExtent

class ShowcaseList extends StatefulWidget {
  ShowcaseList({
    this.tagPrefix,
    this.sourceList,
  });

  final String tagPrefix;
  final SourceList<UnitModel> sourceList;

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
      Key('${widget.tagPrefix}'),
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
                // hack for https://github.com/fluttercandies/loading_more_list/issues/20
                // mainAxisSpacing: 16,
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
              itemBuilder: (BuildContext context, UnitModel item, int index) {
                return ShowcaseItem(
                  unit: item,
                  tagPrefix: widget.tagPrefix,
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
                  isSliver: true,
                );
              },
              // hack for https://github.com/fluttercandies/loading_more_list/issues/20
              padding: EdgeInsets.symmetric(horizontal: 16),
              // lastChildLayoutType: LastChildLayoutType.foot,
            ),
          ),
        ],
      ),
    );
  }
}

// TODO: загрузка блюриной миниатюры, пока грузится большая картинка
// TODO: пока грузится картинка, показывать серый прямоугольник

class ShowcaseItem extends StatefulWidget {
  ShowcaseItem({
    Key key,
    this.unit,
    this.tagPrefix,
    this.isCover,
  }) : super(key: key);

  final UnitModel unit;
  final String tagPrefix;
  final bool isCover;

  @override
  _ShowcaseItemState createState() {
    return _ShowcaseItemState();
  }
}

class _ShowcaseItemState extends State<ShowcaseItem> {
  bool _isBottom = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // hack for https://github.com/fluttercandies/loading_more_list/issues/20
        SizedBox(height: 16),
        _buildImage(),
        _buildBottom(),
      ],
    );
  }

  Widget _buildImage() {
    final unit = widget.unit;
    final isCover = widget.isCover;
    final image = unit.images[0];
    return Material(
      child: InkWell(
        onLongPress: () {}, // чтобы сократить время для splashColor
        onTap: () {
          // Navigator.of(context).push(PageRouteBuilder(
          //   settings: RouteSettings(
          //     arguments: UnitRouteArguments(unit, tag: tag),
          //   ),
          //   pageBuilder: (context, animation, secondaryAnimation) =>
          //       UnitScreen(),
          //   transitionsBuilder:
          //       (context, animation, secondaryAnimation, child) {
          //     return child;
          //   },
          // ));
          setState(() {
            _isBottom = false;
          });
          Navigator.pushNamed(
            context,
            '/unit',
            arguments: UnitRouteArguments(
              unit,
              member: unit.member,
              isShowcase: true,
            ),
          ).then((_) {
            setState(() {
              _isBottom = true;
            });
          });
        },
        splashColor: Colors.white.withOpacity(0.4),
        child: AspectRatio(
          aspectRatio:
              isCover ? 1 / getMagicHeight(1) : image.width / image.height,
          child: Hero(
            tag: '${widget.tagPrefix}-${unit.id}',
            child: Ink.image(
              fit: isCover ? BoxFit.cover : BoxFit.contain,
              image: ExtendedImage.network(
                image.getDummyUrl(unit.id),
                // shape: BoxShape.rectangle,
                // border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1),
                // borderRadius: BorderRadius.all(kImageBorderRadius),
                loadStateChanged: loadStateChanged,
              ).image,
              child: Stack(
                // fit: StackFit.expand,
                children: <Widget>[
                  _buildText(),
                  if (unit.isBlockedOrLocalDeleted)
                    _buildStatus(
                      'Заблокировано',
                      isClosed: true,
                    )
                  else if (unit.transferredAt != null)
                    _buildStatus(
                      'Забрали',
                      isClosed: true,
                    )
                  else if (unit.win != null)
                    _buildStatus(
                      'Завершено',
                      isClosed: true,
                    )
                  else if (unit.expiresAt != null)
                    CountdownTimer(
                      endTime: unit.expiresAt.millisecondsSinceEpoch,
                      builder: (BuildContext context, int seconds) {
                        return _buildStatus(
                          seconds < 1 ? 'Завершено' : formatDDHHMMSS(seconds),
                          isClosed: seconds < 1,
                        );
                      },
                    )
                  else if (unit.urgent != UrgentValue.none)
                    _buildStatus(
                      kUrgents
                          .firstWhere((UrgentModel urgentModel) =>
                              urgentModel.value == unit.urgent)
                          .name,
                      isClosed: false,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottom() {
    final unit = widget.unit;
    if (!_isBottom) {
      return SizedBox(
        height: kButtonHeight,
      );
    }
    return Row(
      children: <Widget>[
        unit.price == null ? GiftButton(unit) : PriceButton(unit),
        Spacer(),
        SizedBox(
          width: kButtonWidth,
          height: kButtonHeight,
          child: ShareButton(unit),
        ),
        SizedBox(
          width: kButtonWidth,
          height: kButtonHeight,
          child: WishButton(unit),
        ),
      ],
    );
  }

  Widget _buildText() {
    final text = widget.unit.text;
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter,
            colors: <Color>[
              Colors.grey.withOpacity(0.0),
              Colors.black.withOpacity(0.4),
            ],
          ),
        ),
        padding: EdgeInsets.only(
          left: 8,
          top: 32,
          right: 8,
          bottom: 8,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildStatus(String data, {bool isClosed}) {
    return Positioned(
      top: 0,
      left: 0,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isClosed
              ? Colors.grey.withOpacity(0.8)
              : Colors.pink.withOpacity(0.8),
          // border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1),
          // borderRadius: BorderRadius.all(Radius.circular(6.5)),
          // borderRadius: BorderRadius.only(
          //   // topLeft: kImageBorderRadius,
          //   bottomRight: kImageBorderRadius,
          // ),
        ),
        child: Text(
          data,
          style: TextStyle(
            fontSize: kFontSize,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
