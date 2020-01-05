import 'package:graphql_flutter/graphql_flutter.dart';

// TODO: заменить class Queries.getItems > namespace queries.getItems

class Queries {
  static final getItems = gql(r'''
    query getItems($next_created_at: timestamptz) {
      item(where: {created_at: {_gte: $next_created_at}}, order_by: {created_at: asc}) {
        id
        created_at
        text
        member {
          id
          nickname
          banned_until
          last_activity_at
        }
        images
        expires_at
        price
        urgent
        location
        is_blocked
        win {
          created_at
        }
        wishes {
          created_at
        }
      }
    }
  ''');

  static final getItemsByKind = gql(r'''
    query getItemsByKind($next_created_at: timestamptz, $kind: kind_enum) {
      item(where: {created_at: {_gte: $next_created_at}, kind: {_eq: $kind}}, order_by: {created_at: asc}) {
        id
        created_at
        text
        member {
          id
          nickname
          banned_until
          last_activity_at
        }
        images
        expires_at
        price
        urgent
        location
        is_blocked
        win {
          created_at
        }
        wishes {
          created_at
        }
      }
    }
  ''');

  static final getProfile = gql(r'''
    query getProfile($member_id: uuid!) {
      member(where: { id: { _eq: $member_id } }) {
        nickname,
        id,
        my_items {
          images
        }
      }
    }
  ''');
}
