import 'package:graphql_flutter/graphql_flutter.dart';

mixin Fragments {
  static final fragments = gql(r'''
    fragment UnitFields on unit {
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
        updated_at
      }
      is_promo
    }

    fragment MemberFields on member {
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
        ...UnitFields
      }
    }

    fragment WantFields on want {
      unit {
        ...UnitFields
        member {
          ...MemberFields
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
