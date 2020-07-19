import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:extended_list/extended_list.dart';
import 'package:minsk8/import.dart';

class WalletScreen extends StatefulWidget {
  @override
  WalletScreenState createState() {
    return WalletScreenState();
  }
}

class WalletScreenState extends State<WalletScreen> {
  final ShowcaseData sourceList = HomeShowcase.dataPool[0];
  List<_WalletItem> _items;

  @override
  void initState() {
    super.initState();
    _items = _normalizeItems();
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
            ExtendedListView.builder(
              // in case list is not full screen and remove ios Bouncing
              physics: const AlwaysScrollableClampingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                final item = _items[index];
                if (item.date != null) {
                  return Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(8),
                    child: Container(
                      child: Text(item.date),
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                    ),
                  );
                }
                final paymentItem = item.paymentItem;
                return ListTile(
                  // TODO: иконка приглашённого пользователя
                  // TODO: иконка системы
                  // TODO: иконка товара
                  leading: CircleAvatar(
                    child: Icon(Icons.image),
                    backgroundColor: Colors.white,
                  ),
                  title: Text(paymentItem.text),
                  subtitle: Text(
                    DateFormat.jm('ru_RU').format(
                      paymentItem.createdAt.toLocal(),
                    ),
                  ),
                  dense: true,
                );
              },
              itemCount: _items.length,
              padding: EdgeInsets.all(0.0),
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

  Future<bool> _onRefresh() {
    return Future<bool>.delayed(const Duration(seconds: 2), () {
      setState(() {});
      return true;
    });
  }

  List<_WalletItem> _normalizeItems() {
    final profile = Provider.of<ProfileModel>(context, listen: false);
    var groupByDate = groupBy<PaymentModel, String>(
      profile.payments,
      (PaymentModel element) =>
          element.createdAt.toLocal().toIso8601String().substring(0, 10),
    );
    final result = <_WalletItem>[];
    groupByDate.forEach((String date, List<PaymentModel> list) {
      result.add(
        _WalletItem(
          // TODO: locale autodetect
          date: DateFormat.yMMMMd('ru_RU').format(
            DateTime.parse(date),
          ),
        ),
      );
      list.forEach(
        (PaymentModel item) {
          result.add(
            _WalletItem(paymentItem: item),
          );
        },
      );
    });
    return result;
  }
}

class _WalletItem {
  _WalletItem({this.date, this.paymentItem})
      : assert((date != null || paymentItem != null) &&
            !(date != null && paymentItem != null));

  String date;
  PaymentModel paymentItem;
}
