import 'package:graphql/client.dart';

mixin Mutations {
  static final insertSuggestion = gql(r'''
    mutation InsertSuggestion($unit_id: uuid $question: question_enum) {
      insert_suggestion(objects: {unit_id: $unit_id, question: $question}) {
        affected_rows
      }
    }
  ''');

  static final upsertModeration = gql(r'''
    mutation UpsertModeration($unit_id: uuid $claim: claim_enum) {
      insert_moderation(objects: {unit_id: $unit_id, claim: $claim}, 
      on_conflict: {constraint: moderation_pkey, update_columns: claim}) {
        affected_rows
      }
    }
  ''');

  static final insertUnit = gql(r'''
    mutation InsertUnit(
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
        ...UnitFields
      }
    }
  ''');

  static final deleteUnit = gql(r'''
    mutation DeleteUnit($id: uuid) {
      update_unit(where: {id: {_eq: $id}}, _set: {is_blocked: true}) {
        affected_rows
      }
    }
  ''');
}
