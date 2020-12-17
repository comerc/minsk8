import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

  // Future<MemberModel> upsertMember(MemberData data) {
  //   return _service.mutate<MemberModel>(
  //     document: API.upsertMember,
  //     variables: data.toJson(),
  //     root: 'insert_member_one',
  //     convert: MemberModel.fromJson,
  //   );
  // }
}

// публично для тестирования
GraphQLService createDefaultService() {
  return GraphQLService(
    client: createClient(),
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

  // static final upsertMember = gql(r'''
  //   mutation UpsertMember($display_name: String $image_url: String) {
  //     insert_member_one(object: {display_name: $display_name, image_url: $image_url},
  //     on_conflict: {constraint: member_pkey, update_columns: [display_name, image_url]}) {
  //       ...MemberFields
  //     }
  //   }
  // ''');

  static final fragments = gql(r'''
    fragment MemberFields on member {
      id
      display_name
      image_url
    }

    fragment UnitFields on unit {
      id
    }
  ''');
}
