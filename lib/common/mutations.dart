import 'package:graphql_flutter/graphql_flutter.dart';
import './fragments.dart';

class Mutations {
  static final insertSuggestion = gql(r'''
    mutation insertSuggestion($unit_id: uuid $question: question_enum) {
      insert_suggestion(objects: {unit_id: $unit_id, question: $question}) {
        affected_rows
      }
    }
  ''');

  static final upsertModeration = gql(r'''
    mutation upsertModeration($unit_id: uuid $claim: claim_enum) {
      insert_moderation(objects: {unit_id: $unit_id, claim: $claim}, 
      on_conflict: {constraint: moderation_pkey, update_columns: claim}) {
        affected_rows
      }
    }
  ''');

  static final insertUnit = gql(r'''
    mutation insertUnit(
      $images: jsonb
      $text: String
      $urgent: urgent_enum
      $kind: kind_enum
      $location: geography
      $address: String
    ) {
      insert_unit_one(object: {
        images: $images
        text: $text
        urgent: $urgent
        kind: $kind
        location: $location
        address: $address
      }) {
        ...unitFields
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final deleteUnit = gql(r'''
    mutation deleteUnit($id: uuid) {
      update_unit(where: {id: {_eq: $id}}, _set: {is_blocked: true}) {
        affected_rows
      }
    }
  ''');

  static final insertWish = gql(r'''
    mutation insertWish($unit_id: uuid) {
      insert_wish_one(object: {unit_id: $unit_id}) {
        created_at
      }
    }
  ''');

  static final deleteWish = gql(r'''
    mutation deleteWish($unit_id: uuid) {
      delete_wish(where: {unit_id: {_eq: $unit_id}}) {
        affected_rows
      }
    }
  ''');
}
