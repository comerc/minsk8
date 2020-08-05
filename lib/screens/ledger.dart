import 'dart:async';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:intl/intl.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:extended_list/extended_list.dart';
import 'package:minsk8/import.dart';

class LedgerScreen extends StatefulWidget {
  static LedgerData sourceList;

  @override
  LedgerScreenState createState() {
    return LedgerScreenState();
  }
}

class LedgerScreenState extends State<LedgerScreen> {
  static bool _isFirst = true;
  static bool _isOpen1 = false;
  static bool _isOpen2 = false;

  @override
  void initState() {
    super.initState();
    if (_isFirst) {
      _isFirst = false;
    } else {
      LedgerScreen.sourceList.refresh(true);
    }
    if (_isOpen1) {
      _isOpen2 = true;
    } else {
      _isOpen1 = true;
    }
  }

  @override
  void dispose() {
    if (!_isOpen2) {
      LedgerScreen.sourceList.clear();
    }
    if (_isOpen2) {
      _isOpen2 = false;
    } else {
      _isOpen1 = false;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = PullToRefreshNotification(
      onRefresh: _onRefresh,
      maxDragOffset: kMaxDragOffset,
      child: Stack(
        children: <Widget>[
          LoadingMoreCustomScrollView(
            rebuildCustomScrollView: true,
            // in case list is not full screen and remove ios Bouncing
            physics: AlwaysScrollableClampingScrollPhysics(),
            slivers: <Widget>[
              LoadingMoreSliverList(
                SliverListConfig<LedgerItem>(
                  extendedListDelegate: ExtendedListDelegate(
                    collectGarbage: (List<int> garbages) {
                      garbages.forEach((int index) {
                        final unit =
                            LedgerScreen.sourceList[index].payment?.unit;
                        if (unit == null) return;
                        final image = unit.images[0];
                        final provider = ExtendedNetworkImageProvider(
                          image.getDummyUrl(unit.id),
                        );
                        provider.evict();
                      });
                    },
                  ),
                  itemBuilder:
                      (BuildContext context, LedgerItem item, int index) {
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
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.all(
                              Radius.circular(kFontSize),
                            ),
                          ),
                        ),
                      );
                    }
                    final payment = item.payment;
                    var textData = {
                      AccountValue.start:
                          'Добро пожаловать! Ловите {{value}} для\u00A0старта\u00A0— пригодятся. Отдайте что-нибудь ненужное, чтобы забирать самые лучшие лоты. Не\u00A0ждите! Добавьте первый лот прямо сейчас!',
                      AccountValue.invite:
                          'Получено {{value}} (всего\u00A0{{balance}}) за\u00A0приглашение участника {{member}}. Приглашайте ещё\u00A0друзей!',
                      AccountValue.unfreeze: <String>[
                        'Разморожено {{value}} (всего\u00A0{{balance}}). Желаем найти что-нибудь интересное!',
                        'Разморожено {{value}} (всего\u00A0{{balance}}). Желаем найти что-нибудь хорошее! 😊',
                        'Разморожено {{value}} (всего\u00A0{{balance}}). Нажмите «Добавить в\u00A0ожидание» на\u00A0лоте, чтобы получать уведомления о\u00A0появлении похожих!',
                      ],
                      AccountValue.freeze:
                          'Ставка на\u00A0лот принята! Заморожено {{value}} (всего\u00A0{{balance}}). Она\u00A0будет разморожена по\u00A0окончанию таймера или при\u00A0отказе от\u00A0лота. Удачи!',
                      AccountValue.limit:
                          'Заявка на\u00A0лот принята. Доступно заявок на\u00A0лоты «Даром»\u00A0— {{limit}}\u00A0в\u00A0день. Осталось сегодня\u00A0— {{value}}. Чтобы увеличить лимит\u00A0— повысьте Карму (всего\u00A0{{balance}}): что-нибудь отдайте или пригласите друзей.',
                      AccountValue.profit:
                          'Получено {{value}} (всего\u00A0{{balance}}) за\u00A0лот. Отдайте ещё что-нибудь ненужное!',
                    }[payment.account];
                    if (textData is List) {
                      var textVariant = payment.textVariant;
                      if (textVariant == null ||
                          textVariant >= (textData as List).length) {
                        textVariant = 0;
                      }
                      textData = (textData as List)[textVariant];
                    }
                    Function action;
                    Widget avatar;
                    String text = textData;
                    <AccountValue, Function>{
                      AccountValue.start: () {
                        action = _getBalanceAction;
                        avatar = CircleAvatar(
                          child: Logo(size: kDefaultIconSize),
                          backgroundColor: Colors.white,
                        );
                        text = interpolate(text, params: {
                          'value': getPluralKarma(payment.value),
                        });
                      },
                      AccountValue.invite: () {
                        action = _getBalanceAction;
                        avatar = Avatar(payment.invitedMember.avatarUrl);
                        text = interpolate(text, params: {
                          'value': getPluralKarma(payment.value),
                          'member': payment.invitedMember.nickname,
                          'balance': payment.balance,
                        });
                      },
                      AccountValue.unfreeze: () {
                        action = _getUnitAction(payment.unit);
                        avatar = Avatar(payment.unit.avatarUrl);
                        text = interpolate(text, params: {
                          'value': getPluralKarma(payment.value),
                          'balance': payment.balance,
                        });
                      },
                      AccountValue.freeze: () {
                        action = _getUnitAction(payment.unit);
                        avatar = Avatar(payment.unit.avatarUrl);
                        text = interpolate(text, params: {
                          'value': getPluralKarma(payment.value.abs()),
                          'balance': payment.balance,
                        });
                      },
                      AccountValue.limit: () {
                        action = _getUnitAction(payment.unit);
                        avatar = Avatar(payment.unit.avatarUrl);
                        text = interpolate(text, params: {
                          'value': payment.value, // это не Карма!
                          'limit': getWantLimit(payment.balance),
                          'balance': payment.balance,
                        });
                      },
                      AccountValue.profit: () {
                        action = _getUnitAction(payment.unit);
                        avatar = Avatar(payment.unit.avatarUrl);
                        text = interpolate(text, params: {
                          'value': getPluralKarma(payment.value),
                          'balance': payment.balance,
                        });
                      },
                    }[payment.account]();
                    return Material(
                      child: InkWell(
                        onLongPress:
                            () {}, // чтобы сократить время для splashColor
                        onTap: action,
                        child: ListTile(
                          leading: avatar,
                          title: Text(text),
                          subtitle: Text(
                            DateFormat.jm('ru_RU').format(
                              payment.createdAt.toLocal(),
                            ),
                          ),
                          dense: true,
                        ),
                      ),
                    );
                  },
                  sourceList: LedgerScreen.sourceList,
                  indicatorBuilder: (
                    BuildContext context,
                    IndicatorStatus status,
                  ) {
                    return buildListIndicator(
                      context: context,
                      status: status,
                      sourceList: LedgerScreen.sourceList,
                    );
                  },
                  lastChildLayoutType: LastChildLayoutType.foot,
                ),
              ),
            ],
          ),
          PullToRefreshContainer((PullToRefreshScrollNotificationInfo info) {
            final offset = info?.dragOffset ?? 0.0;
            return Positioned(
              top: offset - kToolbarHeight,
              left: 0,
              right: 0,
              child: Center(child: info?.refreshWiget),
            );
          }),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Движение Кармы'),
      ),
      body: SafeArea(child: body),
    );
  }

  Future<bool> _onRefresh() async {
    final sourceList = LedgerScreen.sourceList;
    return await sourceList.handleRefresh();
  }

  Function _getUnitAction(UnitModel unit) {
    return () {
      Navigator.pushNamed(
        context,
        '/unit',
        arguments: UnitRouteArguments(
          unit,
          member: unit.member,
        ),
      );
    };
  }

  void _getBalanceAction() {
    showDialog(
      context: context,
      child: BalanceDialog(),
    ).then((value) {
      if (value == null) return;
      Navigator.pushReplacement(
        context,
        buildInitialRoute('/ledger')(
          (_) => LedgerScreen(),
        ),
      );
    });
  }
}
