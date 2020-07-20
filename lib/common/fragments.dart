import 'package:graphql_flutter/graphql_flutter.dart';

// TODO: разблюдовать Fragments.fragments

class Fragments {
  static final fragments = gql(r'''
    fragment itemFields on item {
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
          nickname
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
      nickname
      banned_until
      last_activity_at
      items(
        where: {
          is_winned: {_is_null: true},  
          is_blocked: {_is_null: true}, 
          transferred_at: {_is_null: true}, 
          moderated_at: {_is_null: false}
        }, 
        order_by: {created_at: desc}
      ) {
        ...itemFields
      }
    }

    fragment wantFields on want {
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

    fragment paymentFields on payment {
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
  ''');
}
