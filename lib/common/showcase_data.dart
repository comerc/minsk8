import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:minsk8/import.dart';

class ShowcaseData extends SourceList<UnitModel> {
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
          MetaKindValue.recent: Queries.getUnits,
          MetaKindValue.fan: Queries.getUnitsForFan,
          MetaKindValue.best: Queries.getUnitsForBest,
          MetaKindValue.promo: Queries.getUnitsForPromo,
          MetaKindValue.urgent: Queries.getUnitsForUrgent
        }[kind],
        variables: variables,
        fetchPolicy: FetchPolicy.noCache,
      );
    }
    variables['kind'] = EnumToString.parse(kind);
    return QueryOptions(
      documentNode: Queries.getUnitsByKind,
      variables: variables,
      fetchPolicy: FetchPolicy.noCache,
    );
  }

  @override
  List<UnitModel> getItems(data) {
    final dataItems = [...data['units'] as List];
    // сначала наполняю буфер items, если есть ошибки в UnitModel.fromJson
    final items = <UnitModel>[];
    final hasMore = dataItems.length == kGraphQLUnitsLimit;
    this.hasMore = hasMore;
    if (hasMore) {
      final item = UnitModel.fromJson(dataItems.removeLast());
      nextCreatedAt = item.createdAt.toUtc().toIso8601String();
    }
    for (final dataItem in dataItems) {
      items.add(UnitModel.fromJson(dataItem));
    }
    return items;
  }
}
