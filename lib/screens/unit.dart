import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share/share.dart'; // as share;
import 'package:like_button/like_button.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:minsk8/import.dart';

// TODO: Другие лоты участника показывают только 10 элементов, нужен loadMore
// TODO: [MVP] как отказаться от лота до окончания таймера, по которому мной включён таймер?
// TODO: [MVP] не отображается DistanceButton

class UnitScreen extends StatefulWidget {
  UnitScreen(this.arguments);

  final UnitRouteArguments arguments;

  @override
  _UnitScreenState createState() {
    return _UnitScreenState();
  }
}

// TODO: добавить пункт меню "подписаться на участника"

enum _PopupMenuValue { goToMember, askQuestion, toModerate, delete }

enum _ShowHero { forShowcase, forOpenZoom, forCloseZoom }

class _UnitScreenState extends State<UnitScreen> {
  var _showHero;
  var _isCarouselSlider = true;
  var _currentIndex = 0;
  final _panelColumnKey = GlobalKey();
  double _panelMaxHeight;
  List<UnitModel> _otherUnits;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final unit = widget.arguments.unit;
    if (widget.arguments.isShowcase) {
      _showHero = _ShowHero.forShowcase;
    }
    _initOtherUnits();
    WidgetsBinding.instance.addPostFrameCallback(_onAfterBuild);
    final distance = Provider.of<DistanceModel>(context, listen: false);
    distance.updateValue(unit.location);
    distance.updateCurrentPosition(unit.location);
    analytics.setCurrentScreen(screenName: '/unit ${unit.id}');
  }

  void _onAfterBuild(Duration timeStamp) {
    final renderBox =
        _panelColumnKey.currentContext.findRenderObject() as RenderBox;
    setState(() {
      _panelMaxHeight = renderBox.size.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.arguments.unit;
    final tag = '${HomeScreen.globalKey.currentState.tagPrefix}-${unit.id}';
    final size = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bodyHeight = size.height - statusBarHeight - kToolbarHeight;
    final carouselSliderHeight = bodyHeight / kGoldenRatio -
        UnitCarouselSliderSettings.verticalPadding * 2;
    final panelMinHeight = bodyHeight - bodyHeight / kGoldenRatio;
    final panelChildWidth = size.width - 32.0; // for padding
    final panelSlideLabelWidth = 32.0;
    final separatorWidth = 16.0;
    final otherUnitWidth = (size.width - 4 * separatorWidth) / 3.25;
    final member = widget.arguments.member;
    final child = Stack(
      children: <Widget>[
        SlidingUpPanel(
          body: Column(
            children: <Widget>[
              SizedBox(
                height: UnitCarouselSliderSettings.verticalPadding,
              ),
              Stack(
                children: <Widget>[
                  Container(),
                  if (_showHero != null)
                    Center(
                      child: SizedBox(
                        height: carouselSliderHeight,
                        width: size.width *
                                UnitCarouselSliderSettings.viewportFraction -
                            UnitCarouselSliderSettings.unitHorizontalMargin * 2,
                        child: Hero(
                          tag: tag,
                          child: ExtendedImage.network(
                            unit.images[_currentIndex].getDummyUrl(unit.id),
                            fit: BoxFit.cover,
                            // TODO: если _openDeepLink, то нужно включать
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
                            final hero =
                                flightDirection == HeroFlightDirection.pop &&
                                        _showHero != _ShowHero.forCloseZoom
                                    ? fromHeroContext.widget
                                    : toHeroContext.widget;
                            return (hero as Hero).child;
                          },
                        ),
                      ),
                    ),
                  if (_isCarouselSlider)
                    CarouselSlider(
                      initialPage: _currentIndex,
                      height: carouselSliderHeight,
                      autoPlay: unit.images.length > 1,
                      enableInfiniteScroll: unit.images.length > 1,
                      pauseAutoPlayOnTouch: const Duration(seconds: 10),
                      enlargeCenterPage: true,
                      viewportFraction:
                          UnitCarouselSliderSettings.viewportFraction,
                      onPageChanged: (int index) {
                        _currentIndex = index;
                      },
                      items: List.generate(unit.images.length, (int index) {
                        return Container(
                          width: size.width,
                          margin: EdgeInsets.symmetric(
                              horizontal: UnitCarouselSliderSettings
                                  .unitHorizontalMargin),
                          child: Material(
                            child: InkWell(
                              onLongPress:
                                  () {}, // чтобы сократить время для splashColor
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
                                // ignore: unawaited_futures
                                Navigator.pushNamed(
                                  context,
                                  '/zoom',
                                  arguments: ZoomRouteArguments(
                                    unit,
                                    tag: tag,
                                    index: index,
                                    onWillPop: _onWillPopForZoom,
                                  ),
                                );
                              },
                              splashColor: Colors.white.withOpacity(0.4),
                              child: Ink.image(
                                fit: BoxFit.cover,
                                image: ExtendedImage.network(
                                  unit.images[index].getDummyUrl(unit.id),
                                  loadStateChanged: loadStateChanged,
                                ).image,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                ],
              ),
            ],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          // parallaxEnabled: true,
          // parallaxOffset: .8,
          maxHeight: _panelMaxHeight == null
              ? size.height
              : max(_panelMaxHeight, panelMinHeight),
          minHeight: panelMinHeight,
          panel: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                key: _panelColumnKey,
                children: <Widget>[
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: (panelChildWidth - panelSlideLabelWidth) / 2,
                        child: Row(
                          children: <Widget>[
                            unit.price == null
                                ? GiftButton(unit)
                                : PriceButton(unit),
                            Spacer(),
                          ],
                        ),
                      ),
                      Container(
                        width: panelSlideLabelWidth,
                        height: 4,
                        decoration: ShapeDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          shape: StadiumBorder(),
                        ),
                      ),
                      Container(
                        width: (panelChildWidth - panelSlideLabelWidth) / 2,
                        child: Row(
                          children: <Widget>[
                            Spacer(),
                            DistanceButton(onTap: () {
                              final savedIndex = _currentIndex;
                              setState(() {
                                _isCarouselSlider = false;
                              });
                              Navigator.pushNamed(
                                context,
                                '/unit_map',
                                arguments: UnitMapRouteArguments(
                                  unit,
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
                      unit.text,
                      maxLines: 8,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // if (!unit.isBlockedOrLocalDeleted)
                  //   Container(
                  //     padding: EdgeInsets.only(top: 16),
                  //     width: panelChildWidth,
                  //     child: Text(
                  //       'Самовывоз',
                  //       style: TextStyle(
                  //         color: Colors.black.withOpacity(0.6),
                  //       ),
                  //     ),
                  //   ),
                  if (_otherUnits.isNotEmpty)
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
                  if (_otherUnits.isNotEmpty)
                    Container(
                      padding: EdgeInsets.only(top: 16),
                      width: size.width,
                      height: getMagicHeight(otherUnitWidth),
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: separatorWidth,
                        ),
                        scrollDirection: Axis.horizontal,
                        itemCount: _otherUnits.length,
                        itemBuilder: (BuildContext context, int index) {
                          final otherUnit = _otherUnits[index];
                          return Container(
                            width: otherUnitWidth,
                            child: Material(
                              child: InkWell(
                                // TODO: переключать на следующую картинку
                                // onLongPress: () {},
                                onLongPress:
                                    () {}, // чтобы сократить время для splashColor
                                onTap: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/unit',
                                    (Route route) {
                                      return route.settings.name != '/unit';
                                    },
                                    arguments: UnitRouteArguments(
                                      otherUnit,
                                      member: member,
                                      isShowcase: true,
                                    ),
                                  );
                                },
                                splashColor: Colors.white.withOpacity(0.4),
                                // child : Hero(
                                //   tag: otherUnit.id,
                                //   child:
                                child: Ink.image(
                                  fit: BoxFit.cover,
                                  image: ExtendedImage.network(
                                    otherUnit.images[0]
                                        .getDummyUrl(otherUnit.id),
                                    loadStateChanged: loadStateChanged,
                                  ).image,
                                ),
                                // ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
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
                  colors: <Color>[
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
            children: <Widget>[
              SizedBox(
                width: kBigButtonWidth,
                height: kBigButtonHeight,
                child: ShareButton(unit, iconSize: kBigButtonIconSize),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: kBigButtonWidth,
                height: kBigButtonHeight,
                child: WishButton(unit, iconSize: kBigButtonIconSize),
              ),
              SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: kBigButtonHeight,
                  child: WantButton(unit),
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: ExtendedAppBar(
          title: _buildStatusText(unit),
          centerTitle: true,
          withModel: true,
          // TODO: [MVP] переделать цветовую легенду статуса
          // backgroundColor: unit.isClosed
          //     ? Colors.grey.withOpacity(0.8)
          //     : Colors.pink.withOpacity(0.8),
          actions: <Widget>[
            PopupMenuButton(
              onSelected: (_PopupMenuValue value) async {
                if (value == _PopupMenuValue.delete) {
                  final result = await showDialog(
                    context: context,
                    child: ConfirmDialog(
                        title: 'Вы уверены, что хотите удалить лот?',
                        content:
                            'Размещать его повторно\nзапрещено — возможен бан.',
                        ok: 'Удалить'),
                  );
                  if (result != true) return;
                  // final client = GraphQLProvider.of(context).value;
                  final options = MutationOptions(
                    documentNode: Mutations.deleteUnit,
                    variables: {'id': unit.id},
                    fetchPolicy: FetchPolicy.noCache,
                  );
                  // ignore: unawaited_futures
                  client
                      .mutate(options)
                      .timeout(kGraphQLMutationTimeoutDuration)
                      .then((QueryResult result) {
                    if (result.hasException) {
                      throw result.exception;
                    }
                    if (result.data['update_unit']['affected_rows'] != 1) {
                      throw 'Invalid update_unit.affected_rows';
                    }
                  }).catchError((error) {
                    print(error);
                    if (mounted) {
                      setState(() {
                        localDeletedUnitIds.remove(unit.id);
                      });
                    }
                  });
                  setState(() {
                    localDeletedUnitIds.add(unit.id);
                  });
                }
                if (value == _PopupMenuValue.toModerate) {
                  final result = await showDialog<ClaimValue>(
                    context: context,
                    builder: (BuildContext context) {
                      return EnumModelDialog<ClaimModel>(
                          title: 'Укажите причину жалобы', elements: kClaims);
                    },
                  );
                  if (result == null) return;
                  final snackBar = SnackBar(content: Text('Жалоба принята'));
                  _scaffoldKey.currentState.showSnackBar(snackBar);
                  // final client = GraphQLProvider.of(context).value;
                  final options = MutationOptions(
                    documentNode: Mutations.upsertModeration,
                    variables: {
                      'unit_id': unit.id,
                      'claim': EnumToString.parse(result),
                    },
                    fetchPolicy: FetchPolicy.noCache,
                  );
                  // ignore: unawaited_futures
                  client
                      .mutate(options)
                      .timeout(kGraphQLMutationTimeoutDuration)
                      .then((QueryResult result) {
                    if (result.hasException) {
                      throw result.exception;
                    }
                    if (result.data['insert_moderation']['affected_rows'] !=
                        1) {
                      throw 'Invalid insert_moderation.affected_rows';
                    }
                  }).catchError((error) {
                    print(error);
                  });
                }
                if (value == _PopupMenuValue.askQuestion) {
                  final result = await showDialog<QuestionValue>(
                    context: context,
                    builder: (BuildContext context) {
                      return EnumModelDialog<QuestionModel>(
                          title: 'Что Вы хотите узнать о лоте?',
                          elements: kQuestions);
                    },
                  );
                  if (result == null) return;
                  final snackBar = SnackBar(
                      content: Text(
                          'Вопрос принят и будет передан автору, чтобы дополнил описание'));
                  _scaffoldKey.currentState.showSnackBar(snackBar);
                  // final client = GraphQLProvider.of(context).value;
                  final options = MutationOptions(
                    documentNode: Mutations.insertSuggestion,
                    variables: {
                      'unit_id': unit.id,
                      'question': EnumToString.parse(result),
                    },
                    fetchPolicy: FetchPolicy.noCache,
                  );
                  // ignore: unawaited_futures
                  client
                      .mutate(options)
                      .timeout(kGraphQLMutationTimeoutDuration)
                      .then((QueryResult result) {
                    if (result.hasException) {
                      throw result.exception;
                    }
                    if (result.data['insert_suggestion']['affected_rows'] !=
                        1) {
                      throw 'Invalid insert_suggestion.affected_rows';
                    }
                  }).catchError((error) {
                    print(error);
                  });
                }
              },
              itemBuilder: (BuildContext context) {
                final profile =
                    Provider.of<ProfileModel>(context, listen: false);
                final isMy = profile.member.id == member.id;
                final submenuUnits = <PopupMenuEntry<_PopupMenuValue>>[];
                // TODO: отключил, т.к. требуется реализовать редактирование лота, что будет после MVP
                // if (!isMy && !unit.isClosed) {
                //   submenuUnits.add(PopupMenuItem(
                //     value: _PopupMenuValue.askQuestion,
                //     child: Text('Задать вопрос по лоту'),
                //   ));
                // }
                if (!isMy) {
                  submenuUnits.add(PopupMenuItem(
                    value: _PopupMenuValue.toModerate,
                    child: Text('Пожаловаться на лот'),
                  ));
                }
                if (isMy && !unit.isClosed) {
                  submenuUnits.add(PopupMenuItem(
                    value: _PopupMenuValue.delete,
                    child: Text('Удалить лот'),
                  ));
                }
                return <PopupMenuEntry<_PopupMenuValue>>[
                  PopupMenuItem(
                    value: _PopupMenuValue.goToMember,
                    child: Row(
                      children: <Widget>[
                        Avatar(member.avatarUrl),
                        SizedBox(width: 8),
                        Text(
                          member.displayName,
                          style: TextStyle(
                            fontSize: kFontSize * kGoldenRatio,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (submenuUnits.isNotEmpty) PopupMenuDivider(),
                  ...submenuUnits,
                ];
              },
            ),
          ],
        ),
        body: SafeArea(child: child),
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

  void _initOtherUnits() {
    final memberUnits = widget.arguments.member.units;
    final unit = widget.arguments.unit;
    final result = [...memberUnits];
    result.removeWhere((removeUnit) => removeUnit.id == unit.id);
    _otherUnits = result;
  }

  Widget _buildStatusText(UnitModel unit) {
    if (unit.isBlockedOrLocalDeleted) {
      return Text(
        'Заблокировано',
      );
    }
    if (unit.win != null) {
      return Text(
        'Победитель — ${unit.win.member.displayName}',
      );
    }
    if (unit.expiresAt != null) {
      if (unit.isExpired) {
        return Text('Завершено');
      }
      return CountdownTimer(
          endTime: unit.expiresAt.millisecondsSinceEpoch,
          builder: (BuildContext context, int seconds) {
            return Text(formatDDHHMMSS(seconds));
          },
          onClose: () {
            setState(() {}); // for unit.isClosed
          });
    }
    return Text(
      kUrgents
          .firstWhere(
              (UrgentModel urgentModel) => urgentModel.value == unit.urgent)
          .name,
    );
  }
}

class UnitRouteArguments {
  UnitRouteArguments(
    this.unit, {
    this.member,
    this.isShowcase = false,
  });

  final UnitModel unit;
  final MemberModel member;
  final bool isShowcase;
}

class UnitCarouselSliderSettings {
  static const unitHorizontalMargin = 8.0;
  static const viewportFraction = 0.8;
  static const verticalPadding = 16.0;
}

class WantButton extends StatelessWidget {
  WantButton(this.unit);

  final UnitModel unit;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Want',
      child: Material(
        color: unit.isClosed ? null : Colors.green,
        // borderRadius: BorderRadius.all(kImageBorderRadius),
        child: InkWell(
          splashColor: Colors.white.withOpacity(0.4),
          // borderRadius: BorderRadius.all(kImageBorderRadius),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              _getText(),
              style: TextStyle(
                fontSize: 18,
                color: unit.isClosed
                    ? Colors.black.withOpacity(0.8)
                    : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                // сначала isLocalDeleted, потом isBlocked
                if (unit.isLocalDeleted) {
                  return InfoDialog(
                    icon: FontAwesomeIcons.ban,
                    title: 'Лот удалён',
                    description: 'Вы удалили этот лот',
                  );
                }
                if (unit.isBlocked ?? false) {
                  return InfoDialog(
                    icon: FontAwesomeIcons.ban,
                    title: 'Лот заблокирован',
                    description:
                        'Когда всё хорошо начиналось,\nно потом что-то пошло не так',
                  );
                }
                if (unit.win != null) {
                  return InfoDialog(
                    icon: FontAwesomeIcons.trophy,
                    title:
                        'Лот получил(а) — ${unit.win.member.displayName}. УРА!',
                    description:
                        'Следите за новыми лотами —\nзаберите тоже что-то крутое\n\nИли что-нибудь отдайте!',
                  );
                }
                if (unit.isExpired) {
                  return InfoDialog(
                    icon: FontAwesomeIcons.frog,
                    title: 'Аукцион по лоту завершён',
                    description:
                        'Дождитесь объявления победителя,\nвозможно именно Вам повезёт!',
                  );
                }
                return WantDialog(unit);
              },
            );
          },
        ),
      ),
    );
  }

  String _getText() {
    if ((unit.isBlocked ?? false) || unit.isLocalDeleted) {
      return 'ЗАБЛОКИРОВАНО';
    }
    if (unit.win != null) {
      return 'УЖЕ ЗАБРАЛИ';
    }
    return unit.isExpired ? 'ЗАВЕРШЕНО' : 'ХОЧУ ЗАБРАТЬ';
  }
}

// TODO: учитывать, что участник может быть заблокирован (на добавление новых аукционов, как минимум)

// TODO: [MVP] кнопка ОК и её функционал
// https://hasura.io/docs/1.0/graphql/manual/api-reference/schema-metadata-api/scheduled-triggers.html
// https://hasura.io/docs/1.0/graphql/manual/scheduled-triggers/create-one-off-scheduled-event.html

// class WantDialog extends StatefulWidget {
//   WantDialog(this.unit);

//   final UnitModel unit;

//   @override
//   _WantDialogState createState() {
//     return _WantDialogState();
//   }
// }

// class _WantDialogState extends State<WantDialog> {
class WantDialog extends StatelessWidget {
  WantDialog(this.unit);

  final UnitModel unit;

  static final autoIncreaseFieldKey = GlobalKey<AutoIncreaseFieldState>();

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileModel>(context, listen: false);
    final imageHeight = 96.0;
    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(vertical: 16),
      children: <Widget>[
        Center(
          child: Stack(
            children: <Widget>[
              Container(
                height: imageHeight,
                width: imageHeight,
                margin: EdgeInsets.only(bottom: kButtonHeight / 2),
                child: ExtendedImage.network(
                  unit.images[0].getDummyUrl(unit.id),
                  fit: BoxFit.cover,
                  enableLoadState: false,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    unit.price == null
                        ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.all(8),
                            child: Logo(size: kButtonIconSize),
                          )
                        : Container(
                            color: Colors.white,
                            child: Container(
                              color: Colors.yellow.withOpacity(0.5),
                              height: kButtonHeight,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                unit.price.toString(),
                                style: TextStyle(
                                  fontSize: kPriceFontSize,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Text(
          unit.price == null
              ? 'Точно сможете забрать?'
              : 'Предложить ${getPluralKarma(unit.price + 1)}?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 8),
        Tooltip(
          message: 'Show Map',
          child: ListTile(
            dense: true,
            title: Text(
              'Самовывоз',
              // такой же стиль для 'Автоповышение ставки'
              style: TextStyle(
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            subtitle: unit.address == null
                ? null
                : ConstrainedBox(
                    constraints:
                        BoxConstraints(maxWidth: 0), // TODO: убрать hack
                    child: Text(
                      unit.address,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
            trailing: Icon(
              Icons.navigate_next,
              color: Colors.black.withOpacity(0.3),
              size: kButtonIconSize,
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/unit_map',
                arguments: UnitMapRouteArguments(unit),
              );
            },
          ),
        ),
        Divider(height: 1),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: AutoIncreaseField(
            key: autoIncreaseFieldKey,
            price: unit.price,
            balance: 20, // profile.balance,
          ),
        ),
        Divider(height: 1),
        SizedBox(height: 16),
        Text(
          unit.price == null
              ? 'Только ${getWantLimit(profile.balance)} лотов даром в\u00A0день'
              : 'Карма заморозится до\u00A0конца таймера',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: kFontSize,
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OutlineButton(
              child: Text('Отмена'),
              onLongPress: () {}, // чтобы сократить время для splashColor
              onPressed: () {
                Navigator.of(context).pop();
              },
              textColor: Colors.black.withOpacity(0.8),
            ),
            SizedBox(
              width: 16,
            ),
            FlatButton(
              child: Text(unit.price == null ? 'Да' : 'Хорошо'),
              onLongPress: () {}, // чтобы сократить время для splashColor
              onPressed: () {
                final end = autoIncreaseFieldKey.currentState.currentValue;
                print(end);
                // TODO: если покупатель хочет редактировать end, то нужно добавить поле внутри WantModel
                Navigator.of(context).pop(true);
              },
              color: Colors.green,
              textColor: Colors.white,
            ),
          ],
        ),
      ],
    );
  }
}

const Duration _kExpand = Duration(milliseconds: 200);

class AutoIncreaseField extends StatefulWidget {
  AutoIncreaseField({Key key, this.price, this.balance}) : super(key: key);

  final int price;
  final int balance;

  @override
  AutoIncreaseFieldState createState() {
    return AutoIncreaseFieldState();
  }
}

class AutoIncreaseFieldState extends State<AutoIncreaseField>
    with TickerProviderStateMixin {
  FixedExtentScrollController _controller;
  bool _isExpanded = false;
  int get _minValue => widget.price == null ? 2 : widget.price + 3;
  int _currentValue;

  int get currentValue => _currentValue;

  final _values = kPaymentSteps
      .map<int>(
        (PaymentStepModel element) => element.amount,
      )
      .toList();

  @override
  void initState() {
    super.initState();
    _currentValue = _minValue + 10;
    _controller = FixedExtentScrollController(initialItem: _currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final needValue = max(0, _currentValue - widget.balance);
    final step = getNearestStep(_values, needValue);
    final header = Tooltip(
      message:
          _isExpanded ? 'Выключить автоповышение' : 'Включить автоповышение',
      child: SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(
          'Автоповышение ставки',
          // такой же стиль для 'Самовывоз'
          style: TextStyle(
            color: Colors.black.withOpacity(0.8),
          ),
        ),
        value: _isExpanded,
        onChanged: (bool value) {
          setState(() {
            _isExpanded = value;
            if (!_isExpanded) {
              // stop
              _controller.jumpToItem(_controller.selectedItem);
            }
          });
        },
      ),
    );
    final message = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 0), // TODO: убрать hack
          child: Text(
            'У Вас только ${getPluralKarma(widget.balance)}. Получите\u00A0ещё, чтобы установить желаемый максимум.',
            style: TextStyle(
              fontSize: kFontSize,
              color: Colors.red,
            ),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        FlatButton(
          child: Text('ПОЛУЧИТЬ ${getPluralKarma(step).toUpperCase()}'),
          onLongPress: () {}, // чтобы сократить время для splashColor
          onPressed: () {
            print(step);
            // TODO: [MVP] переход к оплате
            // Navigator.of(context).pop(true);
          },
          color: Colors.green,
          textColor: Colors.white,
        ),
      ],
    );
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 0), // TODO: убрать hack
          child: Text(
            'Ставка будет повышаться автоматически на\u00A0+${getPluralKarma(1)} до\u00A0заданного максимума:',
            style: TextStyle(
              fontSize: kFontSize,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
        ),
        SizedBox(height: 8),
        Container(
          color: Colors.yellow.withOpacity(0.5),
          height: kButtonHeight,
          child: GlowNotificationWidget(
            ExtendedListWheelScrollView(
              scrollDirection: Axis.horizontal,
              itemExtent: kButtonHeight * kGoldenRatio,
              useMagnifier: true,
              magnification: kGoldenRatio,
              onSelectedItemChanged: (int index) {
                setState(() {
                  _currentValue = index;
                });
              },
              controller: _controller,
              minIndex: _minValue,
              maxIndex: 999999,
              builder: (BuildContext context, int index) {
                return Center(
                  child: Text(
                    index.toString(),
                    style: TextStyle(
                      fontSize: kPriceFontSize / kGoldenRatio,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        _buildAnimatedSize(
          needValue > 0 ? message : Container(),
        ),
        SizedBox(height: 16),
      ],
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        header,
        _buildAnimatedSize(
          Offstage(
            child: body,
            offstage: !_isExpanded,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedSize(Widget child) {
    return AnimatedSize(
      child: child,
      alignment: Alignment.topCenter,
      duration: _kExpand,
      reverseDuration: _kExpand,
      vsync: this,
    );
  }
}

class DistanceButton extends StatelessWidget {
  DistanceButton({this.onTap});

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final distance = Provider.of<DistanceModel>(context);
    if (distance.value == null) {
      return Container();
    }
    final icon = Icons.location_on;
    final iconSize = 16.0;
    Widget text = RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <InlineSpan>[
          WidgetSpan(
            child: SizedBox(
              height: iconSize,
              child: RichText(
                text: TextSpan(
                  text: String.fromCharCode(icon.codePoint),
                  style: TextStyle(
                    fontSize: iconSize,
                    fontFamily: icon.fontFamily,
                    color: Colors.pinkAccent,
                  ),
                ),
              ),
            ),
          ),
          TextSpan(
            style: DefaultTextStyle.of(context).style.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.8),
                ),
            text: distance.value,
          ),
        ],
      ),
    );
    return Tooltip(
      message: 'Distance',
      child: Material(
        color: Colors.white,
        child: InkWell(
          child: Container(
            height: kButtonHeight,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: text,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class ConfirmDialog extends StatelessWidget {
  ConfirmDialog({this.title, this.content, this.cancel, this.ok});

  final String title;
  final String content;
  final String cancel;
  final String ok;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              // fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            content,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              OutlineButton(
                child: Text(cancel ?? 'Отмена'),
                onLongPress: () {}, // чтобы сократить время для splashColor
                onPressed: () {
                  Navigator.of(context).pop();
                },
                textColor: Colors.black.withOpacity(0.8),
              ),
              SizedBox(
                width: 16,
              ),
              FlatButton(
                child: Text(ok),
                onLongPress: () {}, // чтобы сократить время для splashColor
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                color: Colors.green,
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EnumModelDialog<T extends EnumModel> extends StatelessWidget {
  EnumModelDialog({this.title, this.elements});

  final String title;
  final List<T> elements;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          elements.length,
          (int index) => Material(
            color: Colors.white,
            child: InkWell(
              child: ListTile(
                title: Text(elements[index].name),
              ),
              onLongPress: () {}, // чтобы сократить время для splashColor
              onTap: () {
                Navigator.of(context).pop(elements[index].value);
              },
            ),
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Отмена'),
          onLongPress: () {}, // чтобы сократить время для splashColor
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

// TODO: https://github.com/hnvn/flutter_flip_panel

class CountdownTimer extends StatefulWidget {
  CountdownTimer({
    this.endTime,
    this.builder,
    this.onClose,
  });

  final int endTime; // millisecondsSinceEpoch
  final Widget Function(BuildContext context, int seconds) builder;
  final Function onClose;

  @override
  _CountDownState createState() => _CountDownState();

  static int getSeconds(int endTime) {
    return Duration(
      milliseconds: (endTime - DateTime.now().millisecondsSinceEpoch),
    ).inSeconds;
  }
}

class _CountDownState extends State<CountdownTimer> {
  int _seconds;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    if (widget.endTime == null) return;
    _seconds = CountdownTimer.getSeconds(widget.endTime);
    if (_seconds < 1) return;
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (_seconds == 1 && widget.onClose != null) {
        widget.onClose();
        _disposeTimer();
        return;
      }
      setState(
        () {
          if (_seconds < 1) {
            _disposeTimer();
          } else {
            _seconds--;
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _disposeTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _seconds);
  }

  void _disposeTimer() {
    _timer?.cancel();
    _timer = null;
  }
}

String formatDDHHMMSS(int seconds) {
  int days, hours, minutes = 0;
  if (seconds >= 86400) {
    days = (seconds / 86400).floor();
    seconds -= days * 86400;
  } else {
    // if days = -1 => Don't show;
    days = -1;
  }
  if (seconds >= 3600) {
    hours = (seconds / 3600).floor();
    seconds -= hours * 3600;
  } else {
    // hours = days == -1 ? -1 : 0;
    hours = 0;
  }
  if (seconds >= 60) {
    minutes = (seconds / 60).floor();
    seconds -= minutes * 60;
  } else {
    // minutes = hours == -1 ? -1 : 0;
    minutes = 0;
  }
  var sDD = (days).toString().padLeft(2, '0');
  var sHH = (hours).toString().padLeft(2, '0');
  var sMM = (minutes).toString().padLeft(2, '0');
  var sSS = (seconds).toString().padLeft(2, '0');
  if (days == -1) {
    return '$sHH:$sMM:$sSS';
  }
  return '$sDD:$sHH:$sMM:$sSS';
}

class GiftButton extends StatelessWidget {
  GiftButton(this.unit);

  final UnitModel unit;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Gift',
      child: Material(
        child: InkWell(
          // borderRadius: BorderRadius.all(kImageBorderRadius),
          child: Container(
            height: kButtonHeight,
            width: kButtonWidth,
            child: Logo(size: kButtonIconSize),
          ),
          onTap: () {
            showDialog(
              context: context,
              child: InfoDialog(
                title: 'Заберите лот даром, если\nне будет других желающих',
                description:
                    'Нажмите "хочу забрать",\n дождитесь окончания таймера',
              ),
            );
          },
        ),
      ),
    );
  }
}

class InfoDialog extends StatelessWidget {
  InfoDialog({
    this.icon,
    this.title,
    this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      children: <Widget>[
        (icon == null)
            ? Logo(size: kButtonIconSize)
            : Icon(
                icon,
                color: Colors.deepOrangeAccent,
                size: kButtonIconSize,
              ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            description,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 8),
          alignment: Alignment.center,
          child: Tooltip(
            message: 'Goto FAQ',
            child: Material(
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  Navigator.of(context)
                    ..pop()
                    ..pushNamed('/faq');
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Как забирать и отдавать лоты?',
                    style: TextStyle(
                      fontSize: kFontSize,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PriceButton extends StatelessWidget {
  PriceButton(this.unit);

  final UnitModel unit;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Price',
      child: Material(
        color: Colors.yellow.withOpacity(0.5),
        // borderRadius: BorderRadius.all(kImageBorderRadius),
        child: InkWell(
          splashColor: Colors.white.withOpacity(0.4),
          // borderRadius: BorderRadius.all(kImageBorderRadius),
          child: Container(
            height: kButtonHeight,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Text(
              unit.price.toString(),
              style: TextStyle(
                fontSize: kPriceFontSize,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                if (unit.isClosed) {
                  return AlertDialog(
                    content: Text('Сколько предложено за лот'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('ОК'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                }
                return InfoDialog(
                  icon: FontAwesomeIcons.moneyBill,
                  title: 'Сколько сейчас\nпредлагают за лот',
                  description:
                      'Нажмите "хочу забрать",\nчтобы предложить больше',
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// TODO: когда выбираю GMail: "getSlotFromBufferLocked: unknown buffer: 0xae738d40"

class ShareButton extends StatelessWidget {
  ShareButton(
    this.unit, {
    this.iconSize = kButtonIconSize,
  });

  final UnitModel unit;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Share',
      child: Material(
        child: InkWell(
          // borderRadius: BorderRadius.all(kImageBorderRadius),
          child: Container(
            child: Icon(
              Icons.share,
              color: Colors.black.withOpacity(0.8),
              size: iconSize,
            ),
          ),
          onTap: _onTap,
        ),
      ),
    );
  }

  void _onTap() {
    share(unit);
  }
}

// TODO: реализовать ожидание для buildShortLink()
void share(UnitModel unit) async {
  final parameters = DynamicLinkParameters(
    uriPrefix: 'https://minsk8.page.link',
    link: Uri.parse('https://minsk8.example.com/unit?id=${unit.id}'),
    androidParameters: AndroidParameters(
      packageName: 'com.example.minsk8',
      minimumVersion: 1,
    ),
    dynamicLinkParametersOptions: DynamicLinkParametersOptions(
      shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
    ),
    // socialMetaTagParameters: SocialMetaTagParameters(
    //   title: 'Example of a Dynamic Link',
    //   description: 'This link works whether app is installed or not!',
    //   // TODO: The URL to an image related to this link. The image should be at least 300x200 px, and less than 300 KB.
    //   // imageUrl:
    // ),
    navigationInfoParameters: NavigationInfoParameters(
      forcedRedirectEnabled: false,
    ),
  );
  final shortLink = await parameters.buildShortLink();
  final url = shortLink.shortUrl;
  // print('${unit.id} $url');
  // TODO: [MVP] изменить тексты
  // ignore: unawaited_futures
  Share.share(
    'check out my website $url',
    subject: 'Look what I made!',
  );
}

class WishButton extends StatefulWidget {
  WishButton(
    this.unit, {
    this.iconSize = kButtonIconSize,
  });

  final UnitModel unit;
  final double iconSize;

  @override
  _WishButtonState createState() {
    return _WishButtonState();
  }
}

class _WishButtonState extends State<WishButton> {
  Timer _timer;
  final _animationDuration = const Duration(milliseconds: 1000);

  @override
  void dispose() {
    _disposeTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myWishes = Provider.of<MyWishesModel>(context);
    return Tooltip(
      message: 'Wish',
      child: Material(
        child: InkWell(
          // borderRadius: BorderRadius.all(kImageBorderRadius),
          child: LikeButton(
            animationDuration: _animationDuration,
            isLiked: myWishes.has(widget.unit.id),
            likeBuilder: (bool isLiked) {
              if (isLiked) {
                return Icon(
                  Icons.favorite,
                  color: Colors.pinkAccent,
                  size: widget.iconSize,
                );
              }
              return Icon(
                Icons.favorite_border,
                color: Colors.black.withOpacity(0.8),
                size: widget.iconSize,
              );
            },
            likeCountPadding: null,
            likeCount: null, // unit.favorites,
            // countBuilder: (int count, bool isLiked, String text) {
            //   final color = isLiked ? Colors.pinkAccent : Colors.grey;
            //   Widget result;
            //   if (count == 0) {
            //     result = Text(
            //       "love",
            //       style: TextStyle(color: color, fontSize: kFontSize),
            //     );
            //   } else
            //     result = Text(
            //       count >= 1000
            //           ? (count / 1000).toStringAsFixed(1) + "k"
            //           : text,
            //       style: TextStyle(color: color, fontSize: kFontSize),
            //     );
            //   return result;
            // },
            // likeCountAnimationType: unit.favorites < 1000
            //     ? LikeCountAnimationType.part
            //     : LikeCountAnimationType.none,
            onTap: _onTap,
          ),
          onTap: () {},
        ),
      ),
    );
  }

  void _disposeTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<bool> _onTap(bool isLiked) async {
    if (_timer != null) {
      return isLiked;
    }
    _timer = Timer(isLiked ? Duration.zero : _animationDuration, () {
      _disposeTimer();
      final myWishes = Provider.of<MyWishesModel>(context, listen: false);
      _optimisticUpdateWish(
        myWishes,
        unit: widget.unit,
        value: !isLiked,
      );
    });
    return !isLiked;
  }
}

Future<void> _queue = Future.value();

void _optimisticUpdateWish(MyWishesModel myWishes,
    {UnitModel unit, bool value}) {
  final oldUpdatedAt = myWishes.updateWish(
    unitId: unit.id,
    value: value,
  );
  // final client = GraphQLProvider.of(context).value;
  final options = MutationOptions(
    documentNode: Mutations.upsertWish,
    variables: {
      'unit_id': unit.id,
      'value': value,
    },
    fetchPolicy: FetchPolicy.noCache,
  );
  _queue = _queue.then((_) {
    return client
        .mutate(options)
        .timeout(kGraphQLMutationTimeoutDuration)
        .then((QueryResult result) {
      if (result.hasException) {
        throw result.exception;
      }
      final json = result.data['insert_wish_one'];
      myWishes.updateWish(
        unitId: unit.id,
        value: value,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
    });
  }).catchError((error) {
    debugPrint(error.toString());
    myWishes.updateWish(
      unitId: unit.id,
      value: oldUpdatedAt != null,
      updatedAt: oldUpdatedAt,
    );
    BotToast.showNotification(
      title: (_) => Text(
        value
            ? 'Не удалось сохранить желание для "${unit.text}"'
            : 'Не удалось удалить желание для "${unit.text}"',
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
      trailing: (Function close) => FlatButton(
        child: Text(
          'ПОВТОРИТЬ',
          style: TextStyle(
            fontSize: kFontSize,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        onLongPress: () {}, // чтобы сократить время для splashColor
        onPressed: () {
          close();
          _optimisticUpdateWish(myWishes, unit: unit, value: value);
        },
      ),
    );
  });
}
