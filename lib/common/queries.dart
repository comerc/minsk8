import 'package:graphql_flutter/graphql_flutter.dart';
import './fragments.dart';

// TODO: заменить class Queries.getUnits > namespace queries.getUnits
// TODO: а может убрать time zone (timestamptz vs timestamp)?

mixin Queries {
  static final getChats = gql(r'''
    query GetChats {
      chats(
        # where:
        #   {
        #     updated_at: {_lte: $next_date},
        #   },
        order_by: {updated_at: desc}
      ) {
        unit {
          ...UnitFields
          member {
            ...MemberFields
          }
        }
        companion {
          ...MemberFields
        }
        messages
        is_unit_owner_writes_now
        is_companion_writes_now
        updated_at
        stage
        transaction_id
        unit_owner_read_count
        companion_read_count
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getUnit = gql(r'''
    query GetUnit($id: uuid!) {
      unit(id: $id) {
        ...UnitFields
        member {
          ...MemberFields
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getUnits = gql(r'''
    query GetUnits($next_date: timestamptz) {
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
        ...UnitFields
        member {
          ...MemberFields
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getUnitsForFan = gql(r'''
    query GetUnitsForFan($next_date: timestamptz) {
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
        ...UnitFields
        member {
          ...MemberFields
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getUnitsForBest = gql(r'''
    query GetUnitsForBest($next_date: timestamptz) {
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
        ...UnitFields
        member {
          ...MemberFields
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getUnitsForPromo = gql(r'''
    query GetUnitsForPromo($next_date: timestamptz) {
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
        ...UnitFields
        member {
          ...MemberFields
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getUnitsForUrgent = gql(r'''
    query GetUnitsForUrgent($next_date: timestamptz) {
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
        ...UnitFields
        member {
          ...MemberFields
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getUnitsByKind = gql(r'''
    query GetUnitsByKind($next_date: timestamptz, $kind: kind_enum) {
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
        ...UnitFields
        member {
          ...MemberFields
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getProfile = gql(r'''
    query GetProfile($member_id: uuid!) {
      profile(member_id: $member_id) {
        member {
          # memberFields вместе с units, чтобы показывать "Другие лоты участника" после добавления лота 
          ...MemberFields
        }
        balance
      }
      wishes(
        order_by: {updated_at: desc}
      ) {
        updated_at
        unit_id
      }
      blocks(
        order_by: {updated_at: desc}
      ) {
        updated_at
        member_id 
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getPayments = gql(r'''
    query GetPayments($next_date: timestamptz) {
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
          ...UnitFields
          member {
            ...MemberFields
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
    query GetNotices($next_date: timestamptz) {
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
            ...UnitFields
            member {
              ...MemberFields
            }
          }
          text  
        }
        suggestion {
          id
          unit {
            ...UnitFields
            member {
              ...MemberFields
            }
          }
          question
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getWishUnits = gql(r'''
    query GetWishUnits {
      wishes(
        order_by: {updated_at: desc}
      ) {
        updated_at
        unit {
          ...UnitFields
          member {
            ...MemberFields
          }
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getWantUnits = gql(r'''
    query GetWantUnits {
      wants(
        order_by: {updated_at: desc}
      ) {
        ...WantFields
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  // static final getWantUnits = gql(r'''
  //   query GetWantUnits {
  //     wants(
  //       where:
  //         {
  //           is_winned: {_is_null: true},
  //         },
  //       order_by: {updated_at: desc}
  //     ) {
  //       ...WantFields
  //     }
  //   }
  // ''')..definitions.addAll(Fragments.fragments.definitions);

  // static final getTakeUnits = gql(r'''
  //   query GetTakeUnits {
  //     wants(
  //       where:
  //         {
  //           is_winned: {_eq: true},
  //         },
  //       order_by: {updated_at: desc}
  //     ) {
  //       ...WantFields
  //     }
  //   }
  // ''')..definitions.addAll(Fragments.fragments.definitions);

  // static final getPastUnits = gql(r'''
  //   query GetPastUnits {
  //     wants(
  //       where:
  //         {
  //           is_winned: {_eq: false},
  //         },
  //       order_by: {updated_at: desc}
  //     ) {
  //       ...WantFields
  //     }
  //   }
  // ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getGiveUnits = gql(r'''
    query GetGiveUnits {
      gives(
        order_by: {created_at: desc}
      ) {
        created_at
        unit {
          ...UnitFields
          member {
            ...MemberFields
          }
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);
}
