// import 'package:gql/ast.dart';
// import 'package:graphql/client.dart';

// // TODO: выбросить после перехода на GraphQLService
// DocumentNode addFragments(DocumentNode document) {
//   return DocumentNode(definitions: [
//     ...Fragments.document.definitions,
//     ...document.definitions
//   ]);
// }

// mixin Fragments {
//   static final document = gql(r'''
//     fragment UnitFields on unit {
//       id
//       created_at
//       text
//       images
//       expires_at
//       price
//       urgent
//       location
//       address
//       win {
//         created_at
//         member {
//           ...SelfMemberFields
//         }
//       }
//       wishes {
//         updated_at
//       }
//       is_promo
//     }

//     fragment SelfMemberFields on member {
//       id
//       display_name
//       image_url
//       banned_until
//       last_activity_at
//     }

//     fragment MemberFields on member {
//       ...SelfMemberFields
//       units(
//         where: {
//           is_winned: {_is_null: true},
//           is_blocked: {_is_null: true},
//           transferred_at: {_is_null: true},
//           moderated_at: {_is_null: false}
//         },
//         order_by: {created_at: desc}
//       ) {
//         ...UnitFields
//       }
//     }

//     fragment WantFields on want {
//       unit {
//         ...UnitFields
//         member {
//           ...MemberFields
//         }
//       }
//       value
//       updated_at
//       win {
//         created_at
//       }
//     }
//   ''');
// }
