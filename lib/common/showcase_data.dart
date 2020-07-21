import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:minsk8/import.dart';

class ShowcaseData extends SourceList<ItemModel> {
  ShowcaseData(
    GraphQLClient client,
    this.kind,
  )   : assert([MetaKindValue, KindValue].contains(kind.runtimeType)),
        super(client);

  final kind;

  bool get isMetaKind => kind.runtimeType == MetaKindValue;

  @override
  bool get isInfinite => !isMetaKind;

  @override
  QueryOptions get options {
    final variables = {'next_created_at': nextCreatedAt};
    if (isMetaKind) {
      return QueryOptions(
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
    }
    variables['kind'] = EnumToString.parse(kind);
    return QueryOptions(
      documentNode: Queries.getItemsByKind,
      variables: variables,
      fetchPolicy: FetchPolicy.noCache,
    );
  }

  @override
  List<ItemModel> getItems(data) {
    final dataItems = [...data['items'] as List];
    // сначала наполняю буфер items, если есть ошибки в ItemModel.fromJson
    final items = <ItemModel>[];
    final hasMore = dataItems.length == kGraphQLItemsLimit;
    this.hasMore = hasMore;
    if (hasMore) {
      final item = ItemModel.fromJson(dataItems.removeLast());
      nextCreatedAt = item.createdAt.toUtc().toIso8601String();
    }
    for (final dataItem in dataItems) {
      items.add(ItemModel.fromJson(dataItem));
    }
    return items;
  }
}
