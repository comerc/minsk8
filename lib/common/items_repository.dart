import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:minsk8/import.dart';

class ItemsRepository extends LoadingMoreBase<ItemModel> {
  final BuildContext context;
  final kind;

  ItemsRepository(
    this.context,
    this.kind,
  ) : assert([MetaKindId, KindId].contains(kind.runtimeType));

  static final startCreatedAt = DateTime.now().toUtc().toIso8601String();

  bool _isFirst = true;
  bool _hasMore = true;
  bool _forceRefresh = false;
  String _nextCreatedAt = startCreatedAt;

  bool get isMetaKind => kind.runtimeType == MetaKindId;

  @override
  bool get hasMore =>
      _forceRefresh || (_hasMore && (!isMetaKind || this.length < 30));

  @override
  Future<bool> refresh([bool clearBeforeRequest = false]) async {
    _isFirst = true;
    _hasMore = true;
    _nextCreatedAt = startCreatedAt;
    //force to refresh list when you don't want clear list before request
    //for the case, if your list already has 20 items.
    _forceRefresh = !clearBeforeRequest;
    final result = await super.refresh(clearBeforeRequest);
    _forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    bool isSuccess = false;
    try {
      // TODO: may be WatchQueryOptions?
      QueryOptions options;
      final variables = {'next_created_at': _nextCreatedAt};
      if (isMetaKind) {
        options = QueryOptions(
          documentNode: {
            MetaKindId.recent: Queries.getItems,
            MetaKindId.interesting: Queries.getItemsForInteresting,
            MetaKindId.best: Queries.getItemsForBest,
            MetaKindId.promo: Queries.getItemsForPromo,
            MetaKindId.urgent: Queries.getItemsForUrgent
          }[kind],
          variables: variables,
        );
      } else {
        variables['kind'] = describeEnum(kind);
        options = QueryOptions(
          documentNode: Queries.getItemsByKind,
          variables: variables,
        );
      }
      final client = GraphQLProvider.of(context).value;
      // to show loading more clearly, in your app,remove this
      // await Future.delayed(Duration(milliseconds: 500));
      final result = await client.query(options);
      if (result.hasException) {
        throw result.exception;
      }
      final items = [...result.data['items'] as List];
      if (_isFirst) {
        _isFirst = false;
        this.clear();
      }
      _hasMore = items.length == kGraphQLItemsLimit;
      if (_hasMore) {
        final itemElement = ItemModel.fromJson(items.removeLast());
        _nextCreatedAt = itemElement.createdAt.toUtc().toIso8601String();
      }
      for (final item in items) {
        final itemModel = ItemModel.fromJson(item);
        itemModel.isMemberWish = memberWishes.contains(itemModel.id);
        this.add(itemModel);
      }
      isSuccess = true;
    } catch (exception, stack) {
      isSuccess = false;
      print(exception);
      print(stack);
    }
    return isSuccess;
  }
}
