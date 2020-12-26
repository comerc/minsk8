import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart';
import 'package:minsk8/import.dart';

const _kEnableWebsockets = true;

typedef CreateServiceCallback = GraphQLService Function();

class DatabaseRepository {
  DatabaseRepository({
    CreateServiceCallback createService,
  }) : _createService = createService ?? createDefaultService;

  GraphQLService _service;
  final CreateServiceCallback _createService;

  void initializeService() {
    _service = _createService();
  }

  // StreamController<UnitModel> _fetchNewestUnitNotificationController;

  // Stream<UnitModel> get fetchNewestUnitNotification {
  //   if (_fetchNewestUnitNotificationController == null) {
  //     _fetchNewestUnitNotificationController = StreamController<UnitModel>();
  //     _fetchNewestUnitNotificationController.onCancel = () async {
  //       try {
  //         // ignore: unawaited_futures
  //         _fetchNewestUnitNotificationController.close();
  //       } finally {
  //         _fetchNewestUnitNotificationController = null;
  //       }
  //     };
  //   }
  //   return _fetchNewestUnitNotificationController.stream;
  // }

  // Stream<String> get fetchNewUnitNotification {
  //   return _service.subscribe<String>(
  //     document: API.fetchNewUnitNotification,
  //     // variables: {},
  //     toRoot: (dynamic rawJson) {
  //       return (rawJson == null)
  //           ? null
  //           : (rawJson['units'] == null)
  //               ? null
  //               : (rawJson['units'] == [])
  //                   ? null
  //                   : rawJson['units'][0];
  //     },
  //     convert: (Map<String, dynamic> json) => json['id'] as String,
  //   );
  // }

  Future<String> upsertMember(MemberData data) async {
    return normalizeOne<String>(
      data: await _service.mutate(
        document: API.upsertMember,
        variables: data.toJson(),
      ),
      root: 'insert_member_one',
      convert: (json) => json['id'] as String,
    );
  }

  Future<ProfileModel> readProfile(String memberId) async {
    final resultData = await _service.query(
      document: API.readProfile,
      variables: {'member_id': memberId},
    );
    return normalizeOne<ProfileModel>(
      data: resultData,
      root: 'profile',
      convert: ProfileModel.fromJson,
    );
  }

  // Future<BuiltList<WishModel>> readWishes() async {
  //   return normalizeList<WishModel>(
  //     data: await _service.query(
  //       document: API.readWishes,
  //       // variables: {},
  //     ),
  //     root: 'wishes',
  //     convert: WishModel.fromJson,
  //   );
  // }
}

// публично для тестирования
GraphQLService createDefaultService() {
  // TODO: избавиться от глобальное переменной client,
  // когда везде будет через BLoC
  client = createClient();
  return GraphQLService(
    client: client,
    queryTimeout: kGraphQLQueryTimeout,
    mutationTimeout: kGraphQLMutationTimeout,
    fragments: API.fragments,
  );
}

// публично для тестирования
GraphQLClient createClient() {
  final httpLink = HttpLink(
    'https://$kGraphQLEndpoint',
  );
  final authLink = AuthLink(
    getToken: () async {
      final idToken = await FirebaseAuth.instance.currentUser.getIdToken(true);
      return 'Bearer $idToken';
    },
  );
  var link = authLink.concat(httpLink);
  if (_kEnableWebsockets) {
    final websocketLink = WebSocketLink(
      'wss://$kGraphQLEndpoint',
      config: SocketClientConfig(
        initialPayload: () async {
          final idToken =
              await FirebaseAuth.instance.currentUser.getIdToken(true);
          return {
            'headers': {'Authorization': 'Bearer $idToken'},
          };
        },
      ),
    );
    // split request based on type
    link = Link.split(
      (request) => request.isSubscription,
      websocketLink,
      link,
    );
  }
  return GraphQLClient(
    cache: GraphQLCache(),
    link: link,
  );
}

// публично для тестирования
mixin API {
  // static final fetchNewUnitNotification = gql(r'''
  //   subscription FetchNewUnitNotification {
  //     units(
  //       order_by: {created_at: desc},
  //       limit: 1
  //     ) {
  //       id
  //     }
  //   }
  // ''');

  static final upsertMember = gql(r'''
    mutation UpsertMember($display_name: String $image_url: String) {
      insert_member_one(object: {display_name: $display_name, image_url: $image_url},
      on_conflict: {constraint: member_pkey, update_columns: [display_name, image_url]}) {
        id
      }
    }
  ''');

  static final readProfile = gql(r'''
    query ReadProfile($member_id: uuid!) {
      profile(member_id: $member_id) {
        member {
          # MemberFields вместе с units, чтобы показывать "Другие лоты участника" после добавления лота 
          ...MemberFields
        }
        balance
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
    }
  ''');

  // static final readWishes = gql(r'''
  //   query ReadWishes() {
  //     wishes(
  //       order_by: {updated_at: desc}
  //     ) {
  //       unit {
  //         ...UnitFields
  //       }
  //     }
  //   }
  // ''');

  // TODO: убрать дублирование фрагментов
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
          ...SelfMemberFields
        }
      }
      wishes {
        updated_at
      }
      is_promo
    }

    fragment SelfMemberFields on member {
      id
      display_name
      image_url
      banned_until
      last_activity_at
    }

    fragment MemberFields on member {
      ...SelfMemberFields
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

// TODO: выбросить после перехода на GraphQLService
DocumentNode addFragments(DocumentNode document) {
  return DocumentNode(
      definitions: [...API.fragments.definitions, ...document.definitions]);
}
