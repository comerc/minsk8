import 'package:graphql/client.dart';
import 'package:gql/ast.dart';

class GraphQLService {
  GraphQLService({
    this.client,
    this.queryTimeout,
    this.mutationTimeout,
    this.fragments,
  });

  final GraphQLClient client;
  final Duration queryTimeout;
  final Duration mutationTimeout;
  final DocumentNode fragments;

  Future<List<T>> query<T>({
    DocumentNode document,
    Map<String, dynamic> variables,
    String root,
    dynamic Function(dynamic rawJson) toRoot,
    T Function(Map<String, dynamic> json) convert,
  }) async {
    final hasRoot = root != null && root.isNotEmpty;
    final hasToRoot = toRoot != null;
    assert(!(hasRoot && hasToRoot), 'Assign "root" or "toRoot" or nothing');
    final options = QueryOptions(
      document: _addFragments(document),
      variables: variables,
      fetchPolicy: FetchPolicy.noCache,
      errorPolicy: ErrorPolicy.all,
    );
    final queryResult = await client.query(options).timeout(queryTimeout);
    if (queryResult.hasException) {
      throw queryResult.exception;
    }
    final rawJson = hasRoot
        ? queryResult.data[root]
        : hasToRoot
            ? toRoot(queryResult.data)
            : queryResult.data;
    final jsons = (rawJson as List).cast<Map<String, dynamic>>();
    final result = <T>[];
    for (final json in jsons) {
      result.add(convert(json));
    }
    return result;
  }

  Future<T> mutate<T>({
    DocumentNode document,
    Map<String, dynamic> variables,
    String root,
    dynamic Function(dynamic rawJson) toRoot,
    T Function(Map<String, dynamic> json) convert,
  }) async {
    final hasRoot = root != null && root.isNotEmpty;
    final hasToRoot = toRoot != null;
    assert(!(hasRoot && hasToRoot), 'Assign "root" or "toRoot" or nothing');
    final options = MutationOptions(
      document: _addFragments(document),
      variables: variables,
      fetchPolicy: FetchPolicy.noCache,
      errorPolicy: ErrorPolicy.all,
    );
    final mutationResult =
        await client.mutate(options).timeout(mutationTimeout);
    if (mutationResult.hasException) {
      throw mutationResult.exception;
    }
    final rawJson = hasRoot
        ? mutationResult.data[root]
        : hasToRoot
            ? toRoot(mutationResult.data)
            : mutationResult.data;
    final json = rawJson as Map<String, dynamic>;
    return (json == null) ? null : convert(json);
  }

  Stream<T> subscribe<T>({
    DocumentNode document,
    Map<String, dynamic> variables,
    String root,
    dynamic Function(dynamic rawJson) toRoot,
    T Function(Map<String, dynamic> json) convert,
  }) {
    final hasRoot = root != null && root.isNotEmpty;
    final hasToRoot = toRoot != null;
    assert(!(hasRoot && hasToRoot), 'Assign "root" or "toRoot" or nothing');
    final operation = SubscriptionOptions(
      document: _addFragments(document),
      variables: variables,
      fetchPolicy: FetchPolicy.noCache,
      errorPolicy: ErrorPolicy.all,
    );
    return client.subscribe(operation).map((QueryResult queryResult) {
      if (queryResult.hasException) {
        throw queryResult.exception;
      }
      final rawJson = hasRoot
          ? queryResult.data[root]
          : hasToRoot
              ? toRoot(queryResult.data)
              : queryResult.data;
      final json = rawJson as Map<String, dynamic>;
      return (json == null) ? null : convert(json);
    });
  }

  DocumentNode _addFragments(DocumentNode document) {
    return (fragments == null)
        ? document
        : DocumentNode(
            definitions: [...fragments.definitions, ...document.definitions]);
  }
}
