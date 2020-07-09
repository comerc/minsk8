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
}
