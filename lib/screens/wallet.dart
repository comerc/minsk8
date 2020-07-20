import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final myPayments = Provider.of<MyPaymentsModel>(context);
    final items = _normalizeItems(myPayments.payments);
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
                final item = items[index];
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
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.all(
                          Radius.circular(kFontSize),
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
              itemCount: items.length,
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

  Future<bool> _onRefresh() async {
    final options = QueryOptions(
      documentNode: Queries.getMyPayments,
      fetchPolicy: FetchPolicy.noCache,
    );
    final client = GraphQLProvider.of(context).value;
    try {
      final result = await client
          .query(options)
          .timeout(Duration(seconds: kGraphQLQueryTimeout));
      if (result.hasException) {
        throw result.exception;
      }
      final items = <PaymentModel>[];
      final dataItems = [...result.data['payments'] as List];
      for (final dataItem in dataItems) {
        items.add(PaymentModel.fromJson(dataItem));
      }
      final myPayments = Provider.of<MyPaymentsModel>(context, listen: false);
      // ignore: unawaited_futures
      myPayments.update(items);
    } catch (exception, stack) {
      print(exception);
      print(stack);
    }
    return false;
  }

  List<_WalletItem> _normalizeItems(List<PaymentModel> payments) {
    var groupByDate = groupBy<PaymentModel, String>(
      payments,
      (PaymentModel element) =>
          element.createdAt.toLocal().toIso8601String().substring(0, 10),
    );
    final result = <_WalletItem>[];
    groupByDate.forEach((String date, List<PaymentModel> list) {
      result.add(
        _WalletItem(
          // TODO: locale autodetect
          displayDate: DateFormat.yMMMMd('ru_RU').format(
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
  _WalletItem({this.displayDate, this.paymentItem})
      : assert((displayDate != null || paymentItem != null) &&
            !(displayDate != null && paymentItem != null));

  String displayDate;
  PaymentModel paymentItem;
}
