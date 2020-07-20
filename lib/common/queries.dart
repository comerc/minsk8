import 'package:graphql_flutter/graphql_flutter.dart';
import './fragments.dart';

// TODO: заменить class Queries.getItems > namespace queries.getItems

class Queries {
  static final getItem = gql(r'''
    query getItem($id: uuid!) {
      item(id: $id) {
        ...itemFields
        member {
          ...memberFields
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getItems = gql(r'''
    query getItems($next_created_at: timestamptz) {
      items(
        where: 
          {
            created_at: {_lte: $next_created_at},
            is_winned: {_is_null: true},  
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
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getItemsForFan = gql(r'''
    query getItemsForFan($next_created_at: timestamptz) {
      items(
        where: 
          {
            total_wishes: {_is_null: false},
            created_at: {_lte: $next_created_at}, 
            is_winned: {_is_null: true},  
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
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getItemsForBest = gql(r'''
    query getItemsForBest($next_created_at: timestamptz) {
      items(
        where: 
          {
            price: {_is_null: false},
            created_at: {_lte: $next_created_at}, 
            is_winned: {_is_null: true},  
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
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getItemsForPromo = gql(r'''
    query getItemsForPromo($next_created_at: timestamptz) {
      items(
        where: 
          {
            is_promo: {_is_null: false},
            created_at: {_lte: $next_created_at}, 
            is_winned: {_is_null: true},  
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
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getItemsForUrgent = gql(r'''
    query getItemsForUrgent($next_created_at: timestamptz) {
      items(
        where: 
          {
            urgent: {_eq: very_urgent},
            created_at: {_lte: $next_created_at}, 
            is_winned: {_is_null: true},  
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
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getItemsByKind = gql(r'''
    query getItemsByKind($next_created_at: timestamptz, $kind: kind_enum) {
      items(
        where: 
          {
            kind: {_eq: $kind},
            created_at: {_lte: $next_created_at} 
            is_winned: {_is_null: true},  
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
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getProfile = gql(r'''
    query getProfile($member_id: uuid!) {
      profile(member_id: $member_id) {
        member {
          ...memberFields
        }
        balance
      }
      wishes {
        created_at
        item_id
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getMyPayments = gql(r'''
    query getMyPayments {
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
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getMyNotifications = gql(r'''
    query getMyNotifications {
      notifications {
        created_at
        proclamation {
          id
          item {
            ...itemFields
            member {
              ...memberFields
            }
          }
          text  
        }
        suggestion {
          id
          item {
            ...itemFields
            member {
              ...memberFields
            }
          }
          question
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getWishItems = gql(r'''
    query getWishItems {
      wishes(
        order_by: {created_at: desc}
      ) {
        created_at
        item {
          ...itemFields
          member {
            ...memberFields
          }
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final getWantItems = gql(r'''
    query getWantItems {
      wants(
        order_by: {updated_at: desc}
      ) {
        ...wantFields
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  // static final getWantItems = gql(r'''
  //   query getWantItems {
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

  // static final getTakeItems = gql(r'''
  //   query getTakeItems {
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

  // static final getPastItems = gql(r'''
  //   query getPastItems {
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

  static final getGiveItems = gql(r'''
    query getGiveItems {
      gives(
        order_by: {created_at: desc}
      ) {
        created_at
        item {
          ...itemFields
          member {
            ...memberFields
          }
        }
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);
}
