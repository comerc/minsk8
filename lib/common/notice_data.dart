import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:minsk8/import.dart';

// TODO: реализовать абстракцию StickyData для NoticeData и LedgerData

class NoticeData extends SourceList<NoticeItem> {
  // NoticeData(GraphQLClient client) : super(client);

  String _nextDate;

  @override
  bool get isInfinite => true;

  @override
  QueryOptions get options {
    final variables = {'next_date': nextDate};
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
    final hasMore = dataItems.length == kGraphQLStickyLimit;
    this.hasMore = hasMore;
    if (hasMore) {
      final notice = NoticeModel.fromJson(dataItems.removeLast());
      nextDate = notice.createdAt.toUtc().toIso8601String();
    }
    final nowLocal = DateTime.now().toLocal();
    for (final dataItem in dataItems) {
      final notice = NoticeModel.fromJson(dataItem);
      final date =
          notice.createdAt.toLocal().toIso8601String().substring(0, 10);
      if (_nextDate != date) {
        _nextDate = date;
        items.add(
          NoticeItem(
            // TODO: locale autodetect
            displayDate: getDisplayDate(
              nowLocal,
              DateTime.parse(date).toLocal(),
            ),
          ),
        );
      }
      items.add(NoticeItem(notice: notice));
    }
    return items;
  }

  @override
  Future<bool> refresh([bool clearBeforeRequest = false]) async {
    _nextDate = null;
    return super.refresh(clearBeforeRequest);
  }
}

class NoticeItem {
  NoticeItem({this.displayDate, this.notice})
      : assert(displayDate != null || notice != null),
        assert(!(displayDate != null && notice != null));

  String displayDate;
  NoticeModel notice;
}
