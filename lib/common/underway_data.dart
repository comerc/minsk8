import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:minsk8/import.dart';

class UnderwayData extends CommonData {
  UnderwayData(
    GraphQLClient client,
    this.tabValue,
  ) : super(client);

  final UnderwayValue tabValue;

  @override
  QueryOptions get options {
    // final variables = {'next_created_at': nextCreatedAt};
    return QueryOptions(
      documentNode: {
        UnderwayValue.wish: Queries.getWishItems,
        UnderwayValue.want: Queries.getWantItems,
        UnderwayValue.past: Queries.getPastItems,
        UnderwayValue.give: Queries.getGiveItems,
      }[tabValue],
      // variables: variables,
      fetchPolicy: FetchPolicy.noCache,
    );
  }

  @override
  List<ItemModel> getItems(data) {
    final dataItems = [
      ...data[{
        UnderwayValue.wish: 'wishes',
        UnderwayValue.want: 'bids',
        UnderwayValue.past: 'wishes',
        UnderwayValue.give: 'wishes',
      }[tabValue]] as List
    ];
    // сначала наполняю буфер items, если есть ошибки в ItemModel.fromJson
    final items = <ItemModel>[];
    hasMore = false;
    for (final dataItem in dataItems) {
      final metaModel = {
        UnderwayValue.wish: () => WishModel.fromJson(dataItem),
        UnderwayValue.want: () => WantModel.fromJson(dataItem),
        UnderwayValue.past: () => WishModel.fromJson(dataItem),
        UnderwayValue.give: () => WishModel.fromJson(dataItem),
      }[tabValue]();
      final item = normalizeItem(metaModel);
      items.add(item);
    }
    return items;
  }

  ItemModel normalizeItem(metaModel) {
    final item = metaModel.item;
    metaModel.item = null;
    item.meta = metaModel;
    return item;
  }
}
