import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql/client.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:minsk8/import.dart';

// TODO: Другие лоты участника показывают только 10 элементов, нужен loadMore
// TODO: [MVP] как отказаться от лота до окончания таймера, по которому мной включён таймер?
// TODO: [MVP] не отображается _DistanceButton

class UnitScreen extends StatefulWidget {
  Route<T> getRoute<T>() {
    return buildRoute<T>(
      '/unit?id=${unit.id}',
      builder: (_) => this,
      fullscreenDialog: true,
    );
  }

  UnitScreen(
    this.unit, {
    this.member,
    this.isShowcase = false,
  });

  final UnitModel unit;
  final MemberModel member;
  final bool isShowcase;

  @override
  _UnitScreenState createState() {
    return _UnitScreenState();
  }
}

// TODO: добавить пункт меню "подписаться на участника"

enum _PopupMenuValue { goToMember, askQuestion, toModerate, delete }

enum _ShowHero {
  forShowcase,
  // forOpenZoom,
  // forCloseZoom,
}
// TODO: Hero for ZoomScreen

class _UnitScreenState extends State<UnitScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _panelColumnKey = GlobalKey();
  var _isCarouselSlider = true;
  var _currentIndex = 0;
  _ShowHero _showHero;
  double _panelMaxHeight;
  List<UnitModel> _otherUnits;

  @override
  void initState() {
    super.initState();
    final unit = widget.unit;
    if (widget.isShowcase) {
      _showHero = _ShowHero.forShowcase;
    }
    _initOtherUnits();
    WidgetsBinding.instance.addPostFrameCallback(_onAfterBuild);
    final distance = Provider.of<DistanceModel>(context, listen: false);
    distance.updateValue(unit.location);
    distance.updateCurrentPosition(unit.location);
    // analytics.setCurrentScreen(screenName: '/unit?id=${unit.id}');
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
    final unit = widget.unit;
    final tag = '${HomeScreen.globalKey.currentState.tagPrefix}-${unit.id}';
    final size = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bodyHeight = size.height - statusBarHeight - kToolbarHeight;
    final carouselSliderHeight = bodyHeight / kGoldenRatio -
        _UnitCarouselSliderSettings.verticalPadding * 2;
    final panelMinHeight = bodyHeight - bodyHeight / kGoldenRatio;
    final panelChildWidth = size.width - 32.0; // for padding
    final panelSlideLabelWidth = 32.0;
    final separatorWidth = 16.0;
    final otherUnitWidth = (size.width - 4 * separatorWidth) / 3.25;
    final member = widget.member;
    final child = Stack(
      children: <Widget>[
        SlidingUpPanel(
          body: Column(
            children: <Widget>[
              SizedBox(
                height: _UnitCarouselSliderSettings.verticalPadding,
              ),
              Stack(
                children: <Widget>[
                  Container(),
                  if (_showHero != null)
                    Center(
                      child: SizedBox(
                        height: carouselSliderHeight,
                        width: size.width *
                                _UnitCarouselSliderSettings.viewportFraction -
                            _UnitCarouselSliderSettings.unitHorizontalMargin *
                                2,
                        child: Hero(
                          tag: tag,
                          flightShuttleBuilder: (
                            BuildContext flightContext,
                            Animation<double> animation,
                            HeroFlightDirection flightDirection,
                            BuildContext fromHeroContext,
                            BuildContext toHeroContext,
                          ) {
                            animation
                                .addStatusListener((AnimationStatus status) {
                              if ([
                                AnimationStatus.completed,
                                AnimationStatus.dismissed,
                              ].contains(status)) {
                                if (mounted) {
                                  setState(() {
                                    _showHero = null;
                                    // TODO: надо бы тут включать CarouselSlider, но тогда мигает экран
                                    // _isCarouselSlider = true;
                                  });
                                }
                              }
                            });
                            final hero =
                                flightDirection == HeroFlightDirection.pop
                                    // && _showHero != _ShowHero.forCloseZoom
                                    ? fromHeroContext.widget
                                    : toHeroContext.widget;
                            return (hero as Hero).child;
                          },
                          child: ExtendedImage.network(
                            unit.images[_currentIndex].getDummyUrl(unit.id),
                            fit: BoxFit.cover,
                            // TODO: если _openDeepLink, то нужно включать
                            enableLoadState: false,
                          ),
                        ),
                      ),
                    ),
                  if (_isCarouselSlider)
                    CarouselSlider(
                      initialPage: _currentIndex,
                      height: carouselSliderHeight,
                      autoPlay: unit.images.length > 1,
                      enableInfiniteScroll: unit.images.length > 1,
                      pauseAutoPlayOnTouch: Duration(seconds: 10),
                      enlargeCenterPage: true,
                      viewportFraction:
                          // ignore: avoid_redundant_argument_values
                          _UnitCarouselSliderSettings.viewportFraction,
                      onPageChanged: (int index) {
                        _currentIndex = index;
                      },
                      items: List.generate(unit.images.length, (int index) {
                        return Container(
                          width: size.width,
                          margin: EdgeInsets.symmetric(
                              horizontal: _UnitCarouselSliderSettings
                                  .unitHorizontalMargin),
                          child: Material(
                            child: InkWell(
                              onLongPress:
                                  () {}, // чтобы сократить время для splashColor
                              onTap: () async {
                                setState(() {
                                  // _showHero = _ShowHero.forOpenZoom;
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
                                navigator.push(
                                  ZoomScreen(
                                    unit,
                                    tag: tag,
                                    index: index,
                                    onWillPop: _onWillPopForZoom,
                                  ).getRoute(),
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
                      SizedBox(
                        width: (panelChildWidth - panelSlideLabelWidth) / 2,
                        child: Row(
                          children: <Widget>[
                            if (unit.price == null)
                              GiftButton(unit)
                            else
                              PriceButton(unit),
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
                      SizedBox(
                        width: (panelChildWidth - panelSlideLabelWidth) / 2,
                        child: Row(
                          children: <Widget>[
                            Spacer(),
                            _DistanceButton(onTap: () {
                              final savedIndex = _currentIndex;
                              setState(() {
                                _isCarouselSlider = false;
                              });
                              navigator
                                  .push(UnitMapScreen(unit).getRoute())
                                  .then((_) {
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
                          return SizedBox(
                            width: otherUnitWidth,
                            child: Material(
                              child: InkWell(
                                // TODO: переключать на следующую картинку
                                // onLongPress: () {},
                                onLongPress:
                                    () {}, // чтобы сократить время для splashColor
                                onTap: () {
                                  navigator.pushAndRemoveUntil(
                                    UnitScreen(
                                      otherUnit,
                                      member: member,
                                      isShowcase: true,
                                    ).getRoute(),
                                    (Route route) {
                                      return route.settings.name != '/unit';
                                    },
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
                  child: _WantButton(unit),
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
                    child: _ConfirmDialog(
                        title: 'Вы уверены, что хотите удалить лот?',
                        content:
                            'Размещать его повторно\nзапрещено — возможен бан.',
                        ok: 'Удалить'),
                  );
                  if (result != true) return;
                  final options = MutationOptions(
                    document: addFragments(Mutations.deleteUnit),
                    variables: {'id': unit.id},
                    fetchPolicy: FetchPolicy.noCache,
                  );
                  // ignore: unawaited_futures
                  client
                      .mutate(options)
                      .timeout(kGraphQLMutationTimeout)
                      .then((QueryResult result) {
                    if (result.hasException) {
                      throw result.exception;
                    }
                    if (result.data['update_unit']['affected_rows'] != 1) {
                      throw 'Invalid update_unit.affected_rows';
                    }
                  }).catchError((error) {
                    out(error);
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
                      return _EnumModelDialog<ClaimValue>(
                        title: 'Укажите причину жалобы',
                        getName: (ClaimValue value) => getClaimName(value),
                      );
                    },
                  );
                  if (result == null) return;
                  final snackBar = SnackBar(content: Text('Жалоба принята'));
                  _scaffoldKey.currentState.showSnackBar(snackBar);
                  final options = MutationOptions(
                    document: addFragments(Mutations.upsertModeration),
                    variables: {
                      'unit_id': unit.id,
                      'claim': convertEnumToSnakeCase(result),
                    },
                    fetchPolicy: FetchPolicy.noCache,
                  );
                  // ignore: unawaited_futures
                  client
                      .mutate(options)
                      .timeout(kGraphQLMutationTimeout)
                      .then((QueryResult result) {
                    if (result.hasException) {
                      throw result.exception;
                    }
                    if (result.data['insert_moderation']['affected_rows'] !=
                        1) {
                      throw 'Invalid insert_moderation.affected_rows';
                    }
                  }).catchError((error) {
                    out(error);
                  });
                }
                if (value == _PopupMenuValue.askQuestion) {
                  final result = await showDialog<QuestionValue>(
                    context: context,
                    builder: (BuildContext context) {
                      return _EnumModelDialog<QuestionValue>(
                        title: 'Что Вы хотите узнать о лоте?',
                        getName: (QuestionValue value) =>
                            getQuestionName(value),
                      );
                    },
                  );
                  if (result == null) return;
                  final snackBar = SnackBar(
                      content: Text(
                          'Вопрос принят и будет передан автору, чтобы дополнил описание'));
                  _scaffoldKey.currentState.showSnackBar(snackBar);
                  final options = MutationOptions(
                    document: addFragments(Mutations.insertSuggestion),
                    variables: {
                      'unit_id': unit.id,
                      'question': convertEnumToSnakeCase(result),
                    },
                    fetchPolicy: FetchPolicy.noCache,
                  );
                  // ignore: unawaited_futures
                  client
                      .mutate(options)
                      .timeout(kGraphQLMutationTimeout)
                      .then((QueryResult result) {
                    if (result.hasException) {
                      throw result.exception;
                    }
                    if (result.data['insert_suggestion']['affected_rows'] !=
                        1) {
                      throw 'Invalid insert_suggestion.affected_rows';
                    }
                  }).catchError((error) {
                    out(error);
                  });
                }
              },
              itemBuilder: (BuildContext context) {
                final profile = getBloc<ProfileCubit>(context).state.profile;
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
      // _showHero = _ShowHero.forCloseZoom;
      _isCarouselSlider = true;
    });
    return true;
  }

  void _initOtherUnits() {
    final memberUnits = widget.member.units;
    final unit = widget.unit;
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
    return Text(getUrgentName(unit.urgent));
  }
}

class _UnitCarouselSliderSettings {
  static const unitHorizontalMargin = 8.0;
  static const viewportFraction = 0.8;
  static const verticalPadding = 16.0;
}

class _WantButton extends StatelessWidget {
  _WantButton(this.unit);

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
                return _WantDialog(unit);
              },
            );
          },
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
class _WantDialog extends StatelessWidget {
  _WantDialog(this.unit);

  final UnitModel unit;

  static final autoIncreaseFieldKey = GlobalKey<_AutoIncreaseFieldState>();

  @override
  Widget build(BuildContext context) {
    final profile = getBloc<ProfileCubit>(context).state.profile;
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
                    if (unit.price == null)
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(8),
                        child: Logo(size: kButtonIconSize),
                      )
                    else
                      Container(
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
              navigator.push(
                UnitMapScreen(unit).getRoute(),
              );
            },
          ),
        ),
        Divider(height: 1),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _AutoIncreaseField(
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
              onLongPress: () {}, // чтобы сократить время для splashColor
              onPressed: () {
                navigator.pop();
              },
              textColor: Colors.black.withOpacity(0.8),
              child: Text('Отмена'),
            ),
            SizedBox(
              width: 16,
            ),
            FlatButton(
              onLongPress: () {}, // чтобы сократить время для splashColor
              onPressed: () {
                final end = autoIncreaseFieldKey.currentState.currentValue;
                out(end);
                // TODO: если покупатель хочет редактировать end, то нужно добавить поле внутри WantModel
                navigator.pop(true);
              },
              color: Colors.green,
              textColor: Colors.white,
              child: Text(unit.price == null ? 'Да' : 'Хорошо'),
            ),
          ],
        ),
      ],
    );
  }
}

const Duration _kExpand = Duration(milliseconds: 200);

class _AutoIncreaseField extends StatefulWidget {
  _AutoIncreaseField({Key key, this.price, this.balance}) : super(key: key);

  final int price;
  final int balance;

  @override
  _AutoIncreaseFieldState createState() {
    return _AutoIncreaseFieldState();
  }
}

class _AutoIncreaseFieldState extends State<_AutoIncreaseField>
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
          onLongPress: () {}, // чтобы сократить время для splashColor
          onPressed: () {
            out(step);
            // TODO: [MVP] переход к оплате
            // navigator.pop(true);
          },
          color: Colors.green,
          textColor: Colors.white,
          child: Text('ПОЛУЧИТЬ ${getPluralKarma(step).toUpperCase()}'),
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
            offstage: !_isExpanded,
            child: body,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedSize(Widget child) {
    return AnimatedSize(
      alignment: Alignment.topCenter,
      duration: _kExpand,
      reverseDuration: _kExpand,
      vsync: this,
      child: child,
    );
  }
}

class _DistanceButton extends StatelessWidget {
  _DistanceButton({this.onTap});

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final distance = Provider.of<DistanceModel>(context);
    if (distance.value == null) {
      return Container();
    }
    final icon = Icons.location_on;
    final iconSize = 16.0;
    final text = RichText(
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
          onTap: onTap,
          child: Container(
            height: kButtonHeight,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: text,
          ),
        ),
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  _ConfirmDialog({this.title, this.content, this.cancel, this.ok});

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
                onLongPress: () {}, // чтобы сократить время для splashColor
                onPressed: () {
                  navigator.pop();
                },
                textColor: Colors.black.withOpacity(0.8),
                child: Text(cancel ?? 'Отмена'),
              ),
              SizedBox(
                width: 16,
              ),
              FlatButton(
                onLongPress: () {}, // чтобы сократить время для splashColor
                onPressed: () {
                  navigator.pop(true);
                },
                color: Colors.green,
                textColor: Colors.white,
                child: Text(ok),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EnumModelDialog<T> extends StatelessWidget {
  _EnumModelDialog({
    this.title,
    this.values,
    this.getName,
  });

  final String title;
  final List<T> values;
  final String Function(T value) getName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          values.length,
          (int index) => Material(
            color: Colors.white,
            child: InkWell(
              onLongPress: () {}, // чтобы сократить время для splashColor
              onTap: () {
                // TODO: типизировать value
                navigator.pop(values[index]);
              },
              child: ListTile(
                title: Text(getName(values[index])),
              ),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          onLongPress: () {}, // чтобы сократить время для splashColor
          onPressed: () {
            navigator.pop();
          },
          child: Text('Отмена'),
        ),
      ],
    );
  }
}
