import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

class MessagesScreen extends StatefulWidget {
  MessagesScreen(this.arguments);

  final MessagesRouteArguments arguments;

  @override
  MessagesScreenState createState() {
    return MessagesScreenState();
  }
}

class MessagesScreenState extends State<MessagesScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.arguments.chat;
    final unit = chat.unit;
    final avatar = Avatar(unit.avatarUrl);
    final body = Container(
      child: Text(unit.id),
    );
    return Scaffold(
      appBar: ExtendedAppBar(
        title: Tooltip(
          message: 'Go To Unit',
          // TODO: отсутствует InkWell - что с этим делать?
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/unit',
                arguments: UnitRouteArguments(
                  unit,
                  member: unit.member,
                ),
              );
            },
            child: Row(
              children: <Widget>[
                avatar,
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    unit.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: kButtonFontSize,
                      fontWeight: FontWeight.normal,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (String value) async {
              if (value == 'complaint') {
                final memberId = getMemberId(context);
                if (unit.member.id != memberId) {
                  launchFeedback(
                    subject:
                        'Жалоба на отдающего transactionId=${chat.transactionId}',
                    body: 'Здравствуйте! Столкнулся с проблемой ',
                  );
                }
                final myBlocks =
                    Provider.of<MyBlocksModel>(context, listen: false);
                final isBlocked =
                    myBlocks.getBlockIndex(unit.win.member.id) != -1;
                // ignore: unawaited_futures
                showDialog<String>(
                  context: context,
                  child: BlockDialog(isBlocked),
                ).then((String value) {
                  if (value == null) return;
                  final cases = {
                    'block': () {
                      _updateBlock(
                        memberId: unit.win.member.id,
                        value: true,
                      );
                    },
                    'unblock': () {
                      _updateBlock(
                        memberId: unit.win.member.id,
                        value: false,
                      );
                    },
                    'feedback': () {
                      launchFeedback(
                        subject:
                            'Жалоба на победителя transactionId=${chat.transactionId}',
                        body: 'Здравствуйте! Столкнулся с проблемой ',
                      );
                    },
                  };
                  cases[value]();
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem(
                  value: 'complaint',
                  child: Row(
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.flag,
                        size: kBigButtonIconSize,
                        color: Colors.red,
                      ),
                      SizedBox(width: 8),
                      Text('ПОЖАЛОВАТЬСЯ'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: SafeArea(child: body),
    );
  }

  void _updateBlock({String memberId, bool value}) {
    final myBlocks = Provider.of<MyBlocksModel>(context, listen: false);
    final oldUpdatedAt = myBlocks.updateBlock(
      memberId: memberId,
      value: value,
    );
    final client = GraphQLProvider.of(context).value;
    final options = MutationOptions(
      documentNode: Mutations.upsertBlock,
      variables: {
        'member_id': memberId,
        'value': value,
      },
      fetchPolicy: FetchPolicy.noCache,
    );
    client
        .mutate(options)
        .timeout(kGraphQLMutationTimeoutDuration)
        .then((QueryResult result) {
      if (result.hasException) {
        throw result.exception;
      }
      final json = result.data['insert_block_one'];
      myBlocks.updateBlock(
        memberId: memberId,
        value: value,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
    }).catchError((error) {
      myBlocks.updateBlock(
        memberId: memberId,
        value: oldUpdatedAt != null,
        updatedAt: oldUpdatedAt,
      );
      // final snackBar = SnackBar(
      //     content:
      //         Text('Не удалось загрузить фотографию, попробуйте ещё раз'));
      // _scaffoldKey.currentState.showSnackBar(snackBar);

      print(error);
      // TODO: предлагать выполнить операцию повторно
    });
  }
}

class MessagesRouteArguments {
  MessagesRouteArguments({this.chat});

  final ChatModel chat;
}
