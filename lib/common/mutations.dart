import 'package:graphql_flutter/graphql_flutter.dart';

class Mutations {
  static final insertWish = gql(r'''
    mutation insertWish($item_id: uuid) {
      insert_wish(objects: {item_id: $item_id}) {
        affected_rows
      }
    }
  ''');

  static final deleteWish = gql(r'''
    mutation deleteWish($item_id: uuid) {
      delete_wish(where: {item_id: {_eq: $item_id}}) {
        affected_rows
      }
    }
  ''');
}
