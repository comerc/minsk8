import 'package:graphql_flutter/graphql_flutter.dart';
import './fragments.dart';

// TODO: заменить class Queries.getItems > namespace queries.getItems

class Queries {
  static final getItems = gql(r'''
    query getItems($next_created_at: timestamptz) {
      items(
        where: 
          {
            created_at: {_lte: $next_created_at}, 
            is_blocked: {_is_null: true}, 
            transferred_at: {_is_null: true}, 
            moderated_at: {_is_null: false}
          }, 
        order_by: {created_at: desc}
      ) {
        ...itemFields
        member {
          ...memberFields
        }
      }
    }
  ''')..definitions.addAll(Fragments.itemFields.definitions);

  static final getItemsForFan = gql(r'''
    query getItemsForFan($next_created_at: timestamptz) {
      items(
        where: 
          {
            total_wishes: {_is_null: false},
            created_at: {_lte: $next_created_at}, 
            is_blocked: {_is_null: true}, 
            transferred_at: {_is_null: true}, 
            moderated_at: {_is_null: false}
          }, 
        order_by: {total_wishes: desc, created_at: desc}
      ) {
        ...itemFields
        member {
          ...memberFields
        }
      }
    }
  ''')..definitions.addAll(Fragments.itemFields.definitions);

  static final getItemsForBest = gql(r'''
    query getItemsForBest($next_created_at: timestamptz) {
      items(
        where: 
          {
            price: {_is_null: false},
            created_at: {_lte: $next_created_at}, 
            is_blocked: {_is_null: true}, 
            transferred_at: {_is_null: true}, 
            moderated_at: {_is_null: false}
          }, 
        order_by: {price: desc, created_at: desc}
      ) {
        ...itemFields
        member {
          ...memberFields
        }
      }
    }
  ''')..definitions.addAll(Fragments.itemFields.definitions);

  static final getItemsForPromo = gql(r'''
    query getItemsForPromo($next_created_at: timestamptz) {
      items(
        where: 
          {
            is_promo: {_is_null: false},
            created_at: {_lte: $next_created_at}, 
            is_blocked: {_is_null: true}, 
            transferred_at: {_is_null: true}, 
            moderated_at: {_is_null: false}
          }, 
        order_by: {created_at: desc}
      ) {
        ...itemFields
        member {
          ...memberFields
        }
      }
    }
  ''')..definitions.addAll(Fragments.itemFields.definitions);

  static final getItemsForUrgent = gql(r'''
    query getItemsForUrgent($next_created_at: timestamptz) {
      items(
        where: 
          {
            urgent: {_eq: very_urgent},
            created_at: {_lte: $next_created_at}, 
            is_blocked: {_is_null: true}, 
            transferred_at: {_is_null: true}, 
            moderated_at: {_is_null: false}
          }, 
        order_by: {created_at: desc}
      ) {
        ...itemFields
        member {
          ...memberFields
        }
      }
    }
  ''')..definitions.addAll(Fragments.itemFields.definitions);

  static final getItemsByKind = gql(r'''
    query getItemsByKind($next_created_at: timestamptz, $kind: kind_enum) {
      items(
        where: 
          {
            kind: {_eq: $kind},
            created_at: {_lte: $next_created_at} 
            is_blocked: {_is_null: true}, 
            transferred_at: {_is_null: true}, 
            moderated_at: {_is_null: false},
          }, 
        order_by: {created_at: desc}
      ) {
        ...itemFields
        member {
          ...memberFields
        }
      }
    }
  ''')..definitions.addAll(Fragments.itemFields.definitions);

  static final getProfile = gql(r'''
    query getProfile($member_id: uuid!) {
      profile(member_id: $member_id) {
        member {
          ...memberFields
        }
        payments {
          id
          text
          value
          created_at
          item {
            ...itemFields
            member {
              ...memberFields
            }
          }
        }
        wishes {
          created_at
          item {
            ...itemFields
            member {
              ...memberFields
            }
          }
        }
        bids {
          item {
            ...itemFields
            member {
              ...memberFields
            }
          }
          value
          updated_at
          win {
            created_at
          }
        }
      }
    }
  ''')..definitions.addAll(Fragments.itemFields.definitions);
}
