import 'package:graphql/client.dart';
import 'package:minsk8/import.dart';

class LedgerData extends SourceList<LedgerItem> {
  // LedgerData(GraphQLClient client) : super(client);

  String _nextDate;

  @override
  bool get isInfinite => true;

  @override
  QueryOptions get options {
    final variables = {'next_date': nextDate};
    return QueryOptions(
      document: addFragments(Queries.getPayments),
      variables: variables,
      fetchPolicy: FetchPolicy.noCache,
    );
  }

  @override
  List<LedgerItem> getItems(Map<String, dynamic> data) {
    final dataItems = <Map<String, dynamic>>[...data['payments']];
    // сначала наполняю буфер items, если есть ошибки в PaymentModel.fromJson
    final items = <LedgerItem>[];
    final hasMore = dataItems.length == kGraphQLStickyLimit;
    this.hasMore = hasMore;
    if (hasMore) {
      final payment = PaymentModel.fromJson(dataItems.removeLast());
      nextDate = payment.createdAt.toUtc().toIso8601String();
    }
    final nowLocal = DateTime.now().toLocal();
    for (final dataItem in dataItems) {
      final payment = PaymentModel.fromJson(dataItem);
      final date =
          payment.createdAt.toLocal().toIso8601String().substring(0, 10);
      if (_nextDate != date) {
        _nextDate = date;
        items.add(
          LedgerItem(
            // TODO: locale autodetect
            displayDate: getDisplayDate(
              nowLocal,
              DateTime.parse(date).toLocal(),
            ),
          ),
        );
      }
      items.add(LedgerItem(payment: payment));
    }
    return items;
  }

  @override
  Future<bool> refresh([bool clearBeforeRequest = false]) async {
    _nextDate = null;
    return super.refresh(clearBeforeRequest);
  }
}

class LedgerItem {
  LedgerItem({this.displayDate, this.payment})
      : assert(displayDate != null || payment != null),
        assert(!(displayDate != null && payment != null));

  String displayDate;
  PaymentModel payment;
}
