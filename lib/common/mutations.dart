import 'package:graphql_flutter/graphql_flutter.dart';
import './fragments.dart';

class Mutations {
  static final upsertNotification = gql(r'''
    mutation upsertNotification($item_id: uuid $question: question_enum) {
      insert_notification(objects: {item_id: $item_id, question: $question}, 
      on_conflict: {constraint: notification_pkey, update_columns: question}) {
        affected_rows
      }
    }
  ''');

  static final upsertModeration = gql(r'''
    mutation upsertModeration($item_id: uuid $claim: claim_enum) {
      insert_moderation(objects: {item_id: $item_id, claim: $claim}, 
      on_conflict: {constraint: moderation_pkey, update_columns: claim}) {
        affected_rows
      }
    }
  ''');

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
      update_item(where: {id: {_eq: $id}}, _set: {is_blocked: true}) {
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
