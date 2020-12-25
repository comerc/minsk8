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

  Future<Map<String, dynamic>> query({
    DocumentNode document,
    Map<String, dynamic> variables,
  }) async {
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
    return queryResult.data;
  }

  Future<Map<String, dynamic>> mutate({
    DocumentNode document,
    Map<String, dynamic> variables,
  }) async {
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
    return mutationResult.data;
  }

  Stream<Map<String, dynamic>> subscribe<T>({
    DocumentNode document,
    Map<String, dynamic> variables,
  }) {
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
      return queryResult.data;
    });
  }

  DocumentNode _addFragments(DocumentNode document) {
    return (fragments == null)
        ? document
        : DocumentNode(
            definitions: [...fragments.definitions, ...document.definitions]);
  }
}
