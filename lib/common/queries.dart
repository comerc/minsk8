import 'package:graphql_flutter/graphql_flutter.dart';
import './fragments.dart';

// TODO: заменить class Queries.getUnits > namespace queries.getUnits
// TODO: а может убрать time zone (timestamptz vs timestamp)?

class Queries {
  static final getChats = gql(r'''
    query getChats($next_date: timestamptz) {
      chats(
        where:
          {
            updated_at: {_lte: $next_date},
          },
        order_by: {updated_at: desc}
      ) {
        unit {
          ...unitFields
          member {
            ...memberFields
          }
        }
        companion {
          ...memberFields
        }
        messages
        is_unit_owner_writes_now
        is_companion_writes_now
        is_unit_owner_read_all
        is_companion_read_all
        updated_at
        stage
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getUnit = gql(r'''
    query getUnit($id: uuid!) {
      unit(id: $id) {
        ...unitFields
        member {
          ...memberFields
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getUnits = gql(r'''
    query getUnits($next_date: timestamptz) {
      units(
        where: 
          {
            created_at: {_lte: $next_date},
            is_winned: {_is_null: true},  
            is_blocked: {_is_null: true}, 
            transferred_at: {_is_null: true}, 
            moderated_at: {_is_null: false}
          }, 
        order_by: {created_at: desc}
      ) {
        ...unitFields
        member {
          ...memberFields
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getUnitsForFan = gql(r'''
    query getUnitsForFan($next_date: timestamptz) {
      units(
        where: 
          {
            total_wishes: {_is_null: false},
            created_at: {_lte: $next_date}, 
            is_winned: {_is_null: true},  
            is_blocked: {_is_null: true}, 
            transferred_at: {_is_null: true}, 
            moderated_at: {_is_null: false}
          }, 
        order_by: {total_wishes: desc, created_at: desc}
      ) {
        ...unitFields
        member {
          ...memberFields
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getUnitsForBest = gql(r'''
    query getUnitsForBest($next_date: timestamptz) {
      units(
        where: 
          {
            price: {_is_null: false},
            created_at: {_lte: $next_date}, 
            is_winned: {_is_null: true},  
            is_blocked: {_is_null: true}, 
            transferred_at: {_is_null: true}, 
            moderated_at: {_is_null: false}
          }, 
        order_by: {price: desc, created_at: desc}
      ) {
        ...unitFields
        member {
          ...memberFields
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getUnitsForPromo = gql(r'''
    query getUnitsForPromo($next_date: timestamptz) {
      units(
        where: 
          {
            is_promo: {_is_null: false},
            created_at: {_lte: $next_date}, 
            is_winned: {_is_null: true},  
            is_blocked: {_is_null: true}, 
            transferred_at: {_is_null: true}, 
            moderated_at: {_is_null: false}
          }, 
        order_by: {created_at: desc}
      ) {
        ...unitFields
        member {
          ...memberFields
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getUnitsForUrgent = gql(r'''
    query getUnitsForUrgent($next_date: timestamptz) {
      units(
        where: 
          {
            urgent: {_eq: very_urgent},
            created_at: {_lte: $next_date}, 
            is_winned: {_is_null: true},  
            is_blocked: {_is_null: true}, 
            transferred_at: {_is_null: true}, 
            moderated_at: {_is_null: false}
          }, 
        order_by: {created_at: desc}
      ) {
        ...unitFields
        member {
          ...memberFields
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getUnitsByKind = gql(r'''
    query getUnitsByKind($next_date: timestamptz, $kind: kind_enum) {
      units(
        where: 
          {
            kind: {_eq: $kind},
            created_at: {_lte: $next_date} 
            is_winned: {_is_null: true},  
            is_blocked: {_is_null: true}, 
            transferred_at: {_is_null: true}, 
            moderated_at: {_is_null: false},
          }, 
        order_by: {created_at: desc}
      ) {
        ...unitFields
        member {
          ...memberFields
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getProfile = gql(r'''
    query getProfile($member_id: uuid!) {
      profile(member_id: $member_id) {
        member {
          id
          display_name
          photo_url
          banned_until
          last_activity_at
        }
        balance
      }
      wishes {
        created_at
        unit_id
      }
    }
  ''');

  static final getPayments = gql(r'''
    query getPayments($next_date: timestamptz) {
      payments (
        where: 
          {
            created_at: {_lte: $next_date} 
          }, 
        order_by: {created_at: desc}
      ) {
        id
        account
        value
        balance
        created_at
        unit {
          ...unitFields
          member {
            ...memberFields
          }
        }
        invited_member {
          id
          display_name
          photo_url
          banned_until
          last_activity_at
        }
        text_variant
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getNotices = gql(r'''
    query getNotices($next_date: timestamptz) {
      notices (
        where: 
          {
            created_at: {_lte: $next_date} 
          }, 
        order_by: {created_at: desc}
      ) {
        created_at
        proclamation {
          id
          unit {
            ...unitFields
            member {
              ...memberFields
            }
          }
          text  
        }
        suggestion {
          id
          unit {
            ...unitFields
            member {
              ...memberFields
            }
          }
          question
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getWishUnits = gql(r'''
    query getWishUnits {
      wishes(
        order_by: {created_at: desc}
      ) {
        created_at
        unit {
          ...unitFields
          member {
            ...memberFields
          }
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getWantUnits = gql(r'''
    query getWantUnits {
      wants(
        order_by: {updated_at: desc}
      ) {
        ...wantFields
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  // static final getWantUnits = gql(r'''
  //   query getWantUnits {
  //     wants(
  //       where:
  //         {
  //           is_winned: {_is_null: true},
  //         },
  //       order_by: {updated_at: desc}
  //     ) {
  //       ...wantFields
  //     }
  //   }
  // ''')..definitions.addAll(Fragments.fragments.definitions);

  // static final getTakeUnits = gql(r'''
  //   query getTakeUnits {
  //     wants(
  //       where:
  //         {
  //           is_winned: {_eq: true},
  //         },
  //       order_by: {updated_at: desc}
  //     ) {
  //       ...wantFields
  //     }
  //   }
  // ''')..definitions.addAll(Fragments.fragments.definitions);

  // static final getPastUnits = gql(r'''
  //   query getPastUnits {
  //     wants(
  //       where:
  //         {
  //           is_winned: {_eq: false},
  //         },
  //       order_by: {updated_at: desc}
  //     ) {
  //       ...wantFields
  //     }
  //   }
  // ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getGiveUnits = gql(r'''
    query getGiveUnits {
      gives(
        order_by: {created_at: desc}
      ) {
        created_at
        unit {
          ...unitFields
          member {
            ...memberFields
          }
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);
}
