import 'package:graphql_flutter/graphql_flutter.dart';

class Fragments {
  static final fragments = gql(r'''
    fragment unitFields on unit {
      id
      created_at
      text
      images
      expires_at
      price
      urgent
      location
      address
      win {
        created_at
        member {
          id
          display_name
          photo_url
          banned_until
          last_activity_at
        }
      }
      wishes {
        created_at
      }
      is_promo
    }

    fragment memberFields on member {
      id
      display_name
      photo_url
      banned_until
      last_activity_at
      units(
        where: {
          is_winned: {_is_null: true},  
          is_blocked: {_is_null: true}, 
          transferred_at: {_is_null: true}, 
          moderated_at: {_is_null: false}
        }, 
        order_by: {created_at: desc}
      ) {
        ...unitFields
      }
    }

    fragment wantFields on want {
      unit {
        ...unitFields
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
  ''');
}
