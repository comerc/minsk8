import 'package:graphql/client.dart';
import 'package:minsk8/import.dart';

// TODO: [MVP] объединить в один запрос .want .take .past и фильтровать по is_winned на клиенте

class UnderwayData extends SourceList<UnitModel> {
  UnderwayData(
    // GraphQLClient client,
    this.tabValue,
  ); // : super(client);

  final UnderwayValue tabValue;

  @override
  QueryOptions get options {
    // final variables = {'next_date': nextDate};
    final document = {
      UnderwayValue.wish: Queries.getWishUnits,
      UnderwayValue.want: Queries.getWantUnits,
      // UnderwayValue.take: Queries.getTakeUnits,
      // UnderwayValue.past: Queries.getPastUnits,
      UnderwayValue.give: Queries.getGiveUnits,
    }[tabValue];
    return QueryOptions(
      document: addFragments(document),
      // variables: variables,
      fetchPolicy: FetchPolicy.noCache,
    );
  }

  @override
  List<UnitModel> getItems(Map<String, dynamic> data) {
    final dataItems = <Map<String, dynamic>>[
      ...data[{
        UnderwayValue.wish: 'wishes',
        UnderwayValue.want: 'wants',
        // UnderwayValue.take: 'wants',
        // UnderwayValue.past: 'wants',
        UnderwayValue.give: 'gives',
      }[tabValue]]
    ];
    // сначала наполняю буфер items, если есть ошибки в UnitModel.fromJson
    final items = <UnitModel>[];
    hasMore = false;
    for (final dataItem in dataItems) {
      final metaModel = {
        UnderwayValue.wish: () => WishModel.fromJson(dataItem),
        UnderwayValue.want: () => WantModel.fromJson(dataItem),
        // UnderwayValue.take: () => WantModel.fromJson(dataItem),
        // UnderwayValue.past: () => WantModel.fromJson(dataItem),
        UnderwayValue.give: () => GiveModel.fromJson(dataItem),
      }[tabValue]();
      final item = normalizeItem(metaModel);
      items.add(item);
    }
    return items;
  }

  UnitModel normalizeItem(dynamic metaModel) {
    final item = metaModel.unit as UnitModel;
    metaModel.unit = null;
    item.meta = metaModel;
    return item;
  }
}
