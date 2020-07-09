import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:minsk8/import.dart';

class UnderwayData extends CommonData {
  UnderwayData(
    GraphQLClient client,
    this.tabValue,
  ) : super(client);

  final UnderwayTabValue tabValue;

  @override
  QueryOptions get options {
    // final variables = {'next_created_at': nextCreatedAt};
    return QueryOptions(
      documentNode: {
        UnderwayTabValue.wish: Queries.getWishItems,
        UnderwayTabValue.want: Queries.getWantItems,
        UnderwayTabValue.give: Queries.getGiveItems,
        UnderwayTabValue.past: Queries.getPastItems,
      }[tabValue],
      // variables: variables,
      fetchPolicy: FetchPolicy.noCache,
    );
  }

  @override
  List<ItemModel> getItems(data) {
    // final dataItems = [...data['items'] as List];
    // сначала наполняю буфер items, если есть ошибки в ItemModel.fromJson
    final items = <ItemModel>[];
    // hasMore = dataItems.length == kGraphQLItemsLimit;
    // if (hasMore) {
    //   final itemElement = ItemModel.fromJson(dataItems.removeLast());
    //   nextCreatedAt = itemElement.createdAt.toUtc().toIso8601String();
    // }
    // for (final dataItem in dataItems) {
    //   items.add(ItemModel.fromJson(dataItem));
    // }
    return items;
  }
}
