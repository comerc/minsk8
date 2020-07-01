import 'package:flutter/widgets.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:minsk8/import.dart';

class ItemsRepository extends LoadingMoreBase<ItemModel> {
  final BuildContext context;
  final kind;

  ItemsRepository(
    this.context,
    this.kind,
  ) : assert([MetaKindValue, KindValue].contains(kind.runtimeType));

  static bool _isStart = true;

  bool get isMetaKind => kind.runtimeType == MetaKindValue;
  String get startCreatedAt => DateTime.now().toUtc().toIso8601String();

  String nextCreatedAt;
  // bool _isFirst;
  bool _hasMore;
  bool _forceRefresh;

  bool _isHandleRefresh = false;
  bool _isLoadDataByTabChange = false;
  bool get isLoadDataByTabChange => _isLoadDataByTabChange;
  resetIsLoadDataByTabChange() {
    _isLoadDataByTabChange = false;
  }

  @override
  bool get hasMore =>
      _forceRefresh || (_hasMore && (!isMetaKind || this.length < 40));

  @override
  Future<bool> refresh([bool clearBeforeRequest = false]) async {
    // print('refresh');
    nextCreatedAt = startCreatedAt;
    // _isFirst = true;
    _hasMore = true;
    //force to refresh list when you don't want clear list before request
    //for the case, if your list already has 20 items.
    _forceRefresh = !clearBeforeRequest;
    final result = await super.refresh(clearBeforeRequest);
    _forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    // print('isLoadMoreAction: $isLoadMoreAction');
    if (_isHandleRefresh) {
      _isHandleRefresh = false;
    } else if (_isStart) {
      _isStart = false;
    } else if (!isLoadMoreAction) {
      // отсек флагами все другие случаи,
      // это флаг включается при смене таба
      _isLoadDataByTabChange = true;
    }
    // print('loadData $_isLoadDataByTabChange $kind');
    assert(nextCreatedAt != null);
    bool isSuccess = false;
    try {
      // TODO: may be WatchQueryOptions?
      QueryOptions options;
      final variables = {'next_created_at': nextCreatedAt};
      if (isMetaKind) {
        options = QueryOptions(
          documentNode: {
            MetaKindValue.recent: Queries.getItems,
            MetaKindValue.fan: Queries.getItemsForFan,
            MetaKindValue.best: Queries.getItemsForBest,
            MetaKindValue.promo: Queries.getItemsForPromo,
            MetaKindValue.urgent: Queries.getItemsForUrgent
          }[kind],
          variables: variables,
          fetchPolicy: FetchPolicy.noCache,
        );
      } else {
        variables['kind'] = EnumToString.parse(kind);
        options = QueryOptions(
          documentNode: Queries.getItemsByKind,
          variables: variables,
          fetchPolicy: FetchPolicy.noCache,
        );
      }
      final client = GraphQLProvider.of(context).value;
      // to show loading more clearly, in your app,remove this
      // await Future.delayed(Duration(milliseconds: 500));
      final result = await client
          .query(options)
          .timeout(Duration(seconds: kGraphQLQueryTimeout));
      // TODO: после таймаута не даёт второй раз потянуть сверху, чтобы сделать refresh
      if (result.hasException) {
        throw result.exception;
      }
      final items = [...result.data['items'] as List];
      // if (_isFirst) {
      //   _isFirst = false;
      //   this.clear();
      // }
      if (!isLoadMoreAction) {
        this.clear();
      }
      _hasMore = items.length == kGraphQLItemsLimit;
      if (_hasMore) {
        final itemElement = ItemModel.fromJson(items.removeLast());
        nextCreatedAt = itemElement.createdAt.toUtc().toIso8601String();
      }
      for (final item in items) {
        this.add(ItemModel.fromJson(item));
      }
      isSuccess = true;
    } catch (exception, stack) {
      isSuccess = false;
      print(exception);
      print(stack);
    }
    return isSuccess;
  }

  Future<bool> handleRefresh([bool clearBeforeRequest = false]) async {
    _isHandleRefresh = true;
    return refresh(clearBeforeRequest);
  }
}
