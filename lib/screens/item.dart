import 'dart:math';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:minsk8/import.dart';

class ItemScreen extends StatefulWidget {
  ItemScreen(this.arguments);

  final ItemRouteArguments arguments;

  @override
  _ItemScreenState createState() {
    return _ItemScreenState();
  }
}

enum _PopupMenuValue { goToMember, askQuestion, toModerate, delete }

enum _ShowHero { forShowcase, forOpenZoom, forCloseZoom }

class _ItemScreenState extends State<ItemScreen> {
  var _showHero;
  var _isCarouselSlider = true;
  var _currentIndex = 0;
  GlobalKey _panelColumnKey = GlobalKey();
  double _panelMaxHeight;
  List<ItemModel> _otherItems;

  @override
  void initState() {
    super.initState();
    final item = widget.arguments.item;
    if (widget.arguments.isShowcase ?? false) {
      _showHero = _ShowHero.forShowcase;
    }
    _initOtherItems();
    WidgetsBinding.instance.addPostFrameCallback(_onAfterBuild);
    final distance = Provider.of<DistanceModel>(context, listen: false);
    distance.updateValue(item.location);
    distance.updateCurrentPosition(item.location);
  }

  void _onAfterBuild(_) {
    final RenderBox renderBox =
        _panelColumnKey.currentContext.findRenderObject();
    setState(() {
      _panelMaxHeight = renderBox.size.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.arguments.item;
    final tag = widget.arguments.tag;
    final size = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bodyHeight = size.height - statusBarHeight - kToolbarHeight;
    final carouselSliderHeight = bodyHeight / kGoldenRatio -
        ItemCarouselSliderSettings.verticalPadding * 2;
    final panelMinHeight = bodyHeight - bodyHeight / kGoldenRatio;
    final panelChildWidth = size.width - 32.0; // for padding
    final panelSlideLabelWidth = 32.0;
    final separatorWidth = 16.0;
    final otherItemWidth = (size.width - 4 * separatorWidth) / 3.25;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: _buildStatusText(item),
          centerTitle: true,
          backgroundColor: item.isClosed
              ? Colors.grey.withOpacity(0.8)
              : Colors.pink.withOpacity(0.8),
          actions: [
            PopupMenuButton(
              onSelected: (_PopupMenuValue value) {
                if (value == _PopupMenuValue.delete) {
                  // TODO: диалог подтвержения
                  final GraphQLClient client =
                      GraphQLProvider.of(context).value;
                  final options = MutationOptions(
                    documentNode: Mutations.deleteItem,
                    variables: {'id': item.id},
                    fetchPolicy: FetchPolicy.noCache,
                  );
                  client.mutate(options).then((QueryResult result) {
                    if (result.hasException) {
                      throw result.exception;
                    }
                    if (result.data['delete_item']['affected_rows'] != 1) {
                      throw Exception('Invalid delete_item.affected_rows');
                    }
                  }).catchError((error) {
                    print(error);
                    if (mounted) {
                      setState(() {
                        localDeletedItemIds.remove(item.id);
                      });
                    }
                  });
                  setState(() {
                    localDeletedItemIds.add(item.id);
                  });
                }
                if (value == _PopupMenuValue.toModerate) {
                  if (item.isClosed) {
                    // TODO: открыть письмо для жалобы
                  } else {
                    // TODO: открыть диалог
                  }
                }
              },
              itemBuilder: (BuildContext context) {
                final profile =
                    Provider.of<ProfileModel>(context, listen: false);
                final isMy = profile.member.id == item.member.id;
                return <PopupMenuEntry<_PopupMenuValue>>[
                  PopupMenuItem(
                    value: _PopupMenuValue.goToMember,
                    child: Row(
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          child: ExtendedImage.network(
                            item.member.avatarUrl,
                            fit: BoxFit.cover,
                            enableLoadState: false,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          item.member.nickname,
                          style: TextStyle(
                            fontSize: kFontSize * kGoldenRatio,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuDivider(),
                  if (!isMy && !item.isClosed)
                    PopupMenuItem(
                      value: _PopupMenuValue.askQuestion,
                      child: Text('Задать вопрос по лоту'),
                    ),
                  if (!isMy)
                    PopupMenuItem(
                      value: _PopupMenuValue.toModerate,
                      child: Text('Пожаловаться на лот'),
                    ),
                  if (isMy && !item.isClosed)
                    PopupMenuItem(
                      value: _PopupMenuValue.delete,
                      child: Text('Удалить лот'),
                    ),
                ];
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            SlidingUpPanel(
              body: Column(
                children: [
                  SizedBox(
                    height: ItemCarouselSliderSettings.verticalPadding,
                  ),
                  Stack(
                    children: [
                      Container(),
                      if (tag != null && _showHero != null)
                        Center(
                          child: SizedBox(
                            height: carouselSliderHeight,
                            width: size.width *
                                    ItemCarouselSliderSettings
                                        .viewportFraction -
                                ItemCarouselSliderSettings
                                        .itemHorizontalMargin *
                                    2,
                            child: Hero(
                              tag: tag,
                              child: ExtendedImage.network(
                                item.images[_currentIndex].getDummyUrl(item.id),
                                fit: BoxFit.cover,
                                enableLoadState: false,
                              ),
                              flightShuttleBuilder: (
                                BuildContext flightContext,
                                Animation<double> animation,
                                HeroFlightDirection flightDirection,
                                BuildContext fromHeroContext,
                                BuildContext toHeroContext,
                              ) {
                                animation.addListener(() {
                                  if ([
                                    AnimationStatus.completed,
                                    AnimationStatus.dismissed,
                                  ].contains(animation.status)) {
                                    setState(() {
                                      _showHero = null;
                                    });
                                  }
                                });
                                final Hero hero = flightDirection ==
                                            HeroFlightDirection.pop &&
                                        _showHero != _ShowHero.forCloseZoom
                                    ? fromHeroContext.widget
                                    : toHeroContext.widget;
                                return hero.child;
                              },
                            ),
                          ),
                        ),
                      if (_isCarouselSlider)
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              _showHero = _ShowHero.forOpenZoom;
                              _isCarouselSlider = false;
                            });
                            // TODO: ужасно мигает экран и ломается Hero, при смене ориентации
                            // await SystemChrome.setPreferredOrientations([
                            //   DeviceOrientation.landscapeRight,
                            //   DeviceOrientation.landscapeLeft,
                            //   DeviceOrientation.portraitUp,
                            //   DeviceOrientation.portraitDown,
                            // ]);
                            // await Future.delayed(Duration(milliseconds: 100));
                            Navigator.pushNamed(
                              context,
                              '/zoom',
                              arguments: ZoomRouteArguments(
                                item,
                                tag: tag,
                                index: _currentIndex,
                                onWillPop: _onWillPopForZoom,
                              ),
                            );
                          },
                          child: CarouselSlider(
                            initialPage: _currentIndex,
                            height: carouselSliderHeight,
                            autoPlay: item.images.length > 1,
                            enableInfiniteScroll: item.images.length > 1,
                            pauseAutoPlayOnTouch: const Duration(seconds: 10),
                            enlargeCenterPage: true,
                            viewportFraction:
                                ItemCarouselSliderSettings.viewportFraction,
                            onPageChanged: (index) {
                              _currentIndex = index;
                            },
                            items: List.generate(item.images.length, (index) {
                              return Container(
                                width: size.width,
                                margin: EdgeInsets.symmetric(
                                    horizontal: ItemCarouselSliderSettings
                                        .itemHorizontalMargin),
                                child: ExtendedImage.network(
                                  item.images[index].getDummyUrl(item.id),
                                  fit: BoxFit.cover,
                                  loadStateChanged: loadStateChanged,
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              // parallaxEnabled: true,
              // parallaxOffset: .8,
              maxHeight: _panelMaxHeight == null
                  ? size.height
                  : max(_panelMaxHeight, panelMinHeight),
              minHeight: panelMinHeight,
              panel: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    key: _panelColumnKey,
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: (panelChildWidth - panelSlideLabelWidth) / 2,
                            child: Row(
                              children: [
                                item.price == null
                                    ? GiftButton(item)
                                    : PriceButton(item),
                                Spacer(),
                              ],
                            ),
                          ),
                          Container(
                            width: panelSlideLabelWidth,
                            height: 4,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12))),
                          ),
                          Container(
                            width: (panelChildWidth - panelSlideLabelWidth) / 2,
                            child: Row(
                              children: [
                                Spacer(),
                                DistanceButton(onTap: () {
                                  final savedIndex = _currentIndex;
                                  setState(() {
                                    _isCarouselSlider = false;
                                  });
                                  Navigator.pushNamed(
                                    context,
                                    '/item_map',
                                    arguments: ItemMapRouteArguments(
                                      item,
                                    ),
                                  ).then((_) {
                                    setState(() {
                                      _currentIndex = savedIndex;
                                      _isCarouselSlider = true;
                                    });
                                  });
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // TODO: как-то показывать текст, если не влезло (для маленьких экранов)
                      Container(
                        padding: EdgeInsets.only(top: 16),
                        width: panelChildWidth,
                        child: Text(
                          item.text,
                          maxLines: 8,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!item.isLocalDeleted)
                        Container(
                          padding: EdgeInsets.only(top: 16),
                          width: panelChildWidth,
                          child: Text(
                            'Самовывоз',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                        ),
                      if (_otherItems.length > 0 && !item.isLocalDeleted)
                        Container(
                          padding: EdgeInsets.only(top: 24),
                          width: panelChildWidth,
                          child: Text(
                            'Другие лоты участника',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ),
                        ),
                      if (_otherItems.length > 0 && !item.isLocalDeleted)
                        Container(
                          padding: EdgeInsets.only(top: 16),
                          width: size.width,
                          height: otherItemWidth, // * 1,
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(
                              horizontal: separatorWidth,
                            ),
                            scrollDirection: Axis.horizontal,
                            itemCount: _otherItems.length,
                            itemBuilder: (BuildContext context, int index) {
                              final otherItem = _otherItems[index];
                              return Container(
                                width: otherItemWidth,
                                color: Colors.red,
                                child: GestureDetector(
                                  // TODO: т.к. картинки квадратные, можно переключать на следующую
                                  // onLongPress: () {},
                                  onTap: () {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/item',
                                      (Route route) {
                                        return route.settings.name != '/item';
                                      },
                                      arguments: ItemRouteArguments(
                                        otherItem,
                                        tag: otherItem.id,
                                        member: widget.arguments.member,
                                      ),
                                    );
                                  },
                                  child:
                                      // Hero(
                                      //   tag: otherItem.id,
                                      //   child:
                                      ExtendedImage.network(
                                    otherItem.images[0]
                                        .getDummyUrl(otherItem.id),
                                    fit: BoxFit.cover,
                                    enableLoadState: false,
                                  ),
                                  // ),
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return SizedBox(
                                width: separatorWidth,
                              );
                            },
                          ),
                        ),
                      SizedBox(
                        height: 16 + kBigButtonHeight + 16 + 8,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: FractionalOffset.topCenter,
                      end: FractionalOffset.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.4),
                      ],
                    ),
                  ),
                  height: 16 + kBigButtonHeight * 1.5,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              left: 16,
              child: Row(
                children: [
                  SizedBox(
                    width: kBigButtonWidth,
                    height: kBigButtonHeight,
                    child: ShareButton(item, iconSize: kBigButtonIconSize),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    width: kBigButtonWidth,
                    height: kBigButtonHeight,
                    child: WishButton(item, iconSize: kBigButtonIconSize),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: kBigButtonHeight,
                      child: WantButton(item),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    setState(() {
      _currentIndex = 0;
      _showHero = _ShowHero.forShowcase;
      _isCarouselSlider = false;
    });
    // await Future.delayed(Duration(milliseconds: 100));
    return true;
  }

  Future<bool> _onWillPopForZoom(int index) async {
    // TODO: ужасно мигает экран и ломается Hero, при смене ориентации
    // await SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    // ]);
    // await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      _currentIndex = index;
      _showHero = _ShowHero.forCloseZoom;
      _isCarouselSlider = true;
    });
    return true;
  }

  void _initOtherItems() {
    final memberItems = widget.arguments.member.items;
    final item = widget.arguments.item;
    final result = [...memberItems];
    result.removeWhere((removeItem) => removeItem.id == item.id);
    _otherItems = result;
  }

  Widget _buildStatusText(ItemModel item) {
    if (item.isBlocked ?? false || item.isLocalDeleted) {
      return Text(
        'Заблокировано',
      );
    }
    if (item.win != null) {
      return Text(
        'Победитель — ${item.win.member.nickname}',
      );
    }
    if (item.expiresAt != null) {
      if (item.isExpired) {
        return Text('Завершено');
      }
      return CountdownTimer(
          endTime: item.expiresAt.millisecondsSinceEpoch,
          builder: (BuildContext context, int seconds) {
            return Text(formatDDHHMMSS(seconds));
          },
          onClose: () {
            setState(() {}); // for item.isClosed
          });
    }
    return Text(
      urgents
          .firstWhere((urgentModel) => urgentModel.value == item.urgent)
          .name,
    );
  }
}

class ItemRouteArguments {
  ItemRouteArguments(
    this.item, {
    this.tag,
    this.member,
    this.isShowcase,
  });

  final ItemModel item;
  final String tag;
  final MemberModel member;
  final bool isShowcase;
}

class ItemCarouselSliderSettings {
  static const itemHorizontalMargin = 8.0;
  static const viewportFraction = 0.8;
  static const verticalPadding = 16.0;
}
