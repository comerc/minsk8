import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:minsk8/import.dart';

// TODO: bug если одна дата, то пропадает NoticeItem.displayDate после refresh

class NoticeData extends SourceList<NoticeItem> {
  NoticeData(
    GraphQLClient client,
  ) : super(client);

  String _nextDate;

  @override
  bool get isInfinite => true;

  @override
  QueryOptions get options {
    final variables = {'next_created_at': nextCreatedAt};
    return QueryOptions(
      documentNode: Queries.getNotices,
      variables: variables,
      fetchPolicy: FetchPolicy.noCache,
    );
  }

  @override
  List<NoticeItem> getItems(data) {
    final dataItems = <Map<String, dynamic>>[...data['notices']];
    // сначала наполняю буфер items, если есть ошибки в NoticeModel.fromJson
    final items = <NoticeItem>[];
    final hasMore = dataItems.length == kGraphQLPaymentsLimit;
    this.hasMore = hasMore;
    if (hasMore) {
      final notice = NoticeModel.fromJson(dataItems.removeLast());
      nextCreatedAt = notice.createdAt.toUtc().toIso8601String();
    }
    for (final dataItem in dataItems) {
      final notice = NoticeModel.fromJson(dataItem);
      final date =
          notice.createdAt.toLocal().toIso8601String().substring(0, 10);
      if (_nextDate != date) {
        _nextDate = date;
        items.add(
          NoticeItem(
            // TODO: locale autodetect
            displayDate: DateFormat.yMMMMd('ru_RU').format(
              DateTime.parse(date),
            ),
          ),
        );
      }
      items.add(NoticeItem(notice: notice));
    }
    return items;
  }
}

class NoticeItem {
  NoticeItem({this.displayDate, this.notice})
      : assert(displayDate != null || notice != null),
        assert(!(displayDate != null && notice != null));

  String displayDate;
  NoticeModel notice;
}
