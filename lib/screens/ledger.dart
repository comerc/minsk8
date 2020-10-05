import 'package:minsk8/import.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:loading_more_list/loading_more_list.dart';

class LedgerScreen extends StatefulWidget {
  static LedgerData sourceList;

  @override
  _LedgerScreenState createState() {
    return _LedgerScreenState();
  }
}

class _LedgerScreenState extends State<LedgerScreen> {
  static bool _isFirst = true;
  static bool _isOpen1 = false;
  static bool _isOpen2 = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
                          decoration: ShapeDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            shape: StadiumBorder(),
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
                    void Function() action;
                    Widget avatar;
                    var text = textData as String;
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
                          'member': payment.invitedMember.displayName,
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
                      // TODO: слишком большой размер поля индикатора из-за kNavigationBarHeight
                      // TODO: при выполнении handleRefresh не показывать IndicatorStatus.loadingMoreBusying
                      // status: IndicatorStatus.loadingMoreBusying == status
                      //     ? IndicatorStatus.none
                      //     : status,
                      sourceList: LedgerScreen.sourceList,
                      isSliver: true,
                    );
                  },
                  // lastChildLayoutType: LastChildLayoutType.foot,
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
      key: _scaffoldKey,
      appBar: ExtendedAppBar(
        title: Text('Движение Кармы'),
      ),
      body: SafeArea(child: body),
    );
  }

  Future<bool> _onRefresh() async {
    final sourceList = LedgerScreen.sourceList;
    final result = await sourceList.handleRefresh();
    if (!result) {
      final snackBar = SnackBar(
          content:
              Text('Не удалось выполнить обновление. Попробуйте ещё раз.'));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
    return result;
  }

  void Function() _getUnitAction(UnitModel unit) {
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
      child: _BalanceDialog(),
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

// class BalanceDialog extends StatefulWidget {
//   @override
//   _BalanceDialogState createState() {
//     return _BalanceDialogState();
//   }
// }

// class _BalanceDialogState extends State<BalanceDialog> {
//   @override
//   void initState() {
//     super.initState();
//     analytics.setCurrentScreen(screenName: '/balance_dalog');
//   }
class _BalanceDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileModel>(context, listen: false);
    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: <Widget>[
        SizedBox(
          height: 16,
        ),
        Container(
          alignment: Alignment.topCenter,
          child: Avatar(
            profile.member.avatarUrl,
            radius: kBigAvatarRadius,
          ),
        ),
        SizedBox(
          height: 16,
        ),
        Text(
          'У Вас ${getPluralKarma(profile.balance)}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        SizedBox(
          height: 8,
        ),
        OutlineButton(
          child: Text('Движение Кармы'),
          onLongPress: () {}, // чтобы сократить время для splashColor
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          textColor: Colors.green,
        ),
        FlatButton(
          child: Text('Повысить Карму'),
          onLongPress: () {}, // чтобы сократить время для splashColor
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/how_to_pay');
          },
          color: Colors.green,
          textColor: Colors.white,
        ),
      ],
    );
  }
}
