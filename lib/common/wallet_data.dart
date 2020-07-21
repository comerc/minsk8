import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:minsk8/import.dart';

class WalletData extends SourceList<WalletItem> {
  WalletData(
    GraphQLClient client,
  ) : super(client);

  String _nextDate;

  @override
  bool get isInfinite => true;

  @override
  QueryOptions get options {
    final variables = {'next_created_at': nextCreatedAt};
    return QueryOptions(
      documentNode: Queries.getMyPayments,
      variables: variables,
      fetchPolicy: FetchPolicy.noCache,
    );
  }

  @override
  List<WalletItem> getItems(data) {
    final dataItems = [...data['payments'] as List];
    // сначала наполняю буфер items, если есть ошибки в PaymentModel.fromJson
    final items = <WalletItem>[];
    final hasMore = dataItems.length == kGraphQLPaymentsLimit;
    this.hasMore = hasMore;
    if (hasMore) {
      final paymentItem = PaymentModel.fromJson(dataItems.removeLast());
      nextCreatedAt = paymentItem.createdAt.toUtc().toIso8601String();
    }
    for (final dataItem in dataItems) {
      final paymentItem = PaymentModel.fromJson(dataItem);
      final date =
          paymentItem.createdAt.toLocal().toIso8601String().substring(0, 10);
      if (_nextDate != date) {
        _nextDate = date;
        items.add(
          WalletItem(
            // TODO: locale autodetect
            displayDate: DateFormat.yMMMMd('ru_RU').format(
              DateTime.parse(date),
            ),
          ),
        );
      }
      items.add(WalletItem(paymentItem: paymentItem));
    }
    return items;
  }
}

class WalletItem {
  WalletItem({this.displayDate, this.paymentItem})
      : assert((displayDate != null || paymentItem != null) &&
            !(displayDate != null && paymentItem != null));

  String displayDate;
  PaymentModel paymentItem;
}
