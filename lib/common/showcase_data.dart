import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:minsk8/import.dart';

class ShowcaseData extends CommonData {
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
    hasMore = dataItems.length == kGraphQLItemsLimit;
    if (hasMore) {
      final itemElement = ItemModel.fromJson(dataItems.removeLast());
      nextCreatedAt = itemElement.createdAt.toUtc().toIso8601String();
    }
    for (final dataItem in dataItems) {
      items.add(ItemModel.fromJson(dataItem));
    }
    return items;
  }
}
