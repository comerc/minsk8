import 'dart:async';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:intl/intl.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:extended_list/extended_list.dart';
import 'package:minsk8/import.dart';

class WalletScreen extends StatefulWidget {
  static WalletData sourceList;

  @override
  WalletScreenState createState() {
    return WalletScreenState();
  }
}

class WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Движение Кармы'),
      ),
      body: PullToRefreshNotification(
        onRefresh: _onRefresh,
        maxDragOffset: kMaxDragOffset,
        child: Stack(
          children: [
            LoadingMoreCustomScrollView(
              rebuildCustomScrollView: true,
              // in case list is not full screen and remove ios Bouncing
              physics: AlwaysScrollableClampingScrollPhysics(),
              slivers: [
                LoadingMoreSliverList(SliverListConfig<WalletItem>(
                  extendedListDelegate: ExtendedListDelegate(
                    collectGarbage: (List<int> garbages) {
                      garbages.forEach((index) {
                        final unit =
                            WalletScreen.sourceList[index].paymentUnit?.unit;
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
                      (BuildContext context, WalletItem item, int index) {
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
                    final paymentUnit = item.paymentUnit;
                    var accountValue = paymentUnit.account;
                    var text = {
                      // TODO: переработать текст - слишком фамильярно
                      AccountValue.start:
                          'Добро пожаловать! Ловите {{value}} для старта - пригодятся. Отдайте что-нибудь ненужное, чтобы забирать самые лучшие вещи. Не ждите! Добавьте первый лот прямо сейчас!',
                      AccountValue.invite:
                          'Получено {{value}} Кармы за приглашение участника {{nickname}}. Приглашайте ещё друзей!',
                      // TODO: несколько разных текстов для unfreeze
                      AccountValue.unfreeze:
                          'Разморожено {{value}} Кармы. Желаем найти что-нибудь интересное!',
                      AccountValue.freeze:
                          'Заморожено {{value}} Кармы. Она будет разморожена по окончанию таймера или при отказе от лота. Удачи!',
                      AccountValue.limit:
                          'Заявка на лот принята. Доступно заявок на лоты "Даром" — {{limit}} в день. Осталось сегодня — {{value}}. Чтобы увеличить лимит — повысь Карму: что-нибудь отдай или пригласи друзей',
                      AccountValue.profit:
                          'Получено {{value}} Кармы за лот "{{unit}}". Отдайте ещё что-нибудь ненужное!',
                    }[accountValue];
                    if (paymentUnit.account == AccountValue.invite) {
                      // text = interpolate(text, params: {
                      //   'name': paymentUnit.invitedMember.nickname,
                      //   'greet': '${4444}'
                      // });
                    }
                    return ListTile(
                      // TODO: иконка приглашённого пользователя
                      // TODO: иконка системы
                      // TODO: иконка товара
                      leading: CircleAvatar(
                        child: Icon(Icons.image),
                        backgroundColor: Colors.white,
                      ),
                      title: Text(text),
                      subtitle: Text(
                        DateFormat.jm('ru_RU').format(
                          paymentUnit.createdAt.toLocal(),
                        ),
                      ),
                      dense: true,
                    );
                  },
                  sourceList: WalletScreen.sourceList,
                  indicatorBuilder: (
                    BuildContext context,
                    IndicatorStatus status,
                  ) {
                    return buildListIndicator(
                      context: context,
                      status: status,
                      sourceList: WalletScreen.sourceList,
                    );
                  },
                  lastChildLayoutType: LastChildLayoutType.foot,
                ))
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
      ),
    );
  }

  Future<bool> _onRefresh() async {
    final sourceList = WalletScreen.sourceList;
    return await sourceList.handleRefresh();
  }
}
