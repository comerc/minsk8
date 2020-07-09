import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:minsk8/import.dart';

// TODO: переименовать таблицу bid > want

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
        UnderwayTabValue.past: Queries.getPastItems,
        UnderwayTabValue.give: Queries.getGiveItems,
      }[tabValue],
      // variables: variables,
      fetchPolicy: FetchPolicy.noCache,
    );
  }

  @override
  List<ItemModel> getItems(data) {
    final dataItems = [
      ...data[{
        UnderwayTabValue.wish: 'wishes',
        UnderwayTabValue.want: 'bids',
        UnderwayTabValue.past: 'wishes',
        UnderwayTabValue.give: 'wishes',
      }[tabValue]] as List
    ];

    // сначала наполняю буфер items, если есть ошибки в ItemModel.fromJson
    final items = <ItemModel>[];
    for (final dataItem in dataItems) {
      final metaModel = {
        UnderwayTabValue.wish: () => WishModel.fromJson(dataItem),
        UnderwayTabValue.want: () => WantModel.fromJson(dataItem),
        UnderwayTabValue.past: () => WishModel.fromJson(dataItem),
        UnderwayTabValue.give: () => WishModel.fromJson(dataItem),
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
