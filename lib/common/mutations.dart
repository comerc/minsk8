import 'package:graphql_flutter/graphql_flutter.dart';
import './fragments.dart';

class Mutations {
  static final insertItem = gql(r'''
    mutation insertItem(
      $images: jsonb
      $text: String
      $urgent: urgent_enum
      $kind: kind_enum
      $location: geography
      $address: String
    ) {
      insert_item_one(object: {
        images: $images
        text: $text
        urgent: $urgent
        kind: $kind
        location: $location
        address: $address
      }) {
        ...itemFields
      }
    }
  ''')..definitions.addAll(Fragments.itemFields.definitions);

  static final deleteItem = gql(r'''
    mutation deleteItem($id: uuid) {
      delete_item(where: {id: {_eq: $id}}) {
        affected_rows
      }
    }
  ''');

  static final insertWish = gql(r'''
    mutation insertWish($item_id: uuid) {
      insert_wish_one(object: {item_id: $item_id}) {
        created_at
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
