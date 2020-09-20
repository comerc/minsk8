import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
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
                  return;
                }
                final myBlocks =
                    Provider.of<MyBlocksModel>(context, listen: false);
                final isBlocked = myBlocks.has(unit.win.member.id);
                // ignore: unawaited_futures
                showDialog<String>(
                  context: context,
                  child: BlockDialog(isBlocked),
                ).then((String value) {
                  if (value == null) return;
                  final cases = {
                    'block': () {
                      _optimisticUpdateBlock(
                        myBlocks,
                        member: unit.win.member,
                        value: true,
                      );
                    },
                    'unblock': () {
                      _optimisticUpdateBlock(
                        myBlocks,
                        member: unit.win.member,
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
}

class MessagesRouteArguments {
  MessagesRouteArguments({this.chat});

  final ChatModel chat;
}

Future<void> _queue = Future.value();

void _optimisticUpdateBlock(MyBlocksModel myBlocks,
    {MemberModel member, bool value}) {
  final oldUpdatedAt = myBlocks.updateBlock(
    memberId: member.id,
    value: value,
  );
  // final client = GraphQLProvider.of(context).value;
  final options = MutationOptions(
    documentNode: Mutations.upsertBlock,
    variables: {
      'member_id': member.id,
      'value': value,
    },
    fetchPolicy: FetchPolicy.noCache,
  );
  _queue = _queue.then((_) {
    return client
        .mutate(options)
        .timeout(kGraphQLMutationTimeoutDuration)
        .then((QueryResult result) {
      if (result.hasException) {
        throw result.exception;
      }
      final json = result.data['insert_block_one'];
      myBlocks.updateBlock(
        memberId: member.id,
        value: value,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
    });
  }).catchError((error) {
    debugPrint(error.toString());
    myBlocks.updateBlock(
      memberId: member.id,
      value: oldUpdatedAt != null,
      updatedAt: oldUpdatedAt,
    );
    BotToast.showNotification(
      title: (_) => Text(
        value
            ? 'Не удалось заблокировать "${member.displayName}"'
            : 'Не удалось разблокировать "${member.displayName}"',
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
      trailing: (Function close) => FlatButton(
        child: Text(
          'ПОВТОРИТЬ',
          style: TextStyle(
            fontSize: kFontSize,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        onLongPress: () {}, // чтобы сократить время для splashColor
        onPressed: () {
          close();
          _optimisticUpdateBlock(myBlocks, member: member, value: value);
        },
      ),
    );
  });
}
