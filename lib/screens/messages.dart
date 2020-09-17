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
                        isBlocked: false,
                        memberId: unit.win.member.id,
                      );
                    },
                    'unblock': () {
                      _updateBlock(
                        isBlocked: true,
                        memberId: unit.win.member.id,
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

  void _updateBlock({bool isBlocked, String memberId}) {
    final myBlocks = Provider.of<MyBlocksModel>(context, listen: false);
    final index = myBlocks.getBlockIndex(memberId);
    final currentIsBlocked = index != -1;
    // TODO: [MVP] из-за этой проверки может быть рассинхрон с бэком?
    if (isBlocked != currentIsBlocked) {
      return;
    }
    final block = isBlocked
        ? myBlocks.blocks[index] // index check with currentIsBlocked
        : BlockModel(
            createdAt: DateTime.now(),
            memberId: memberId,
          );
    myBlocks.updateBlock(index, block, !isBlocked);
    final client = GraphQLProvider.of(context).value;
    final options = MutationOptions(
      documentNode: isBlocked ? Mutations.deleteBlock : Mutations.insertBlock,
      variables: {'member_id': memberId},
      fetchPolicy: FetchPolicy.noCache,
    );
    client
        .mutate(options)
        .timeout(kGraphQLMutationTimeoutDuration)
        .then((QueryResult result) {
      // TODO: перезаписать createdAt
      if (result.hasException) {
        throw result.exception;
      }
    }).catchError((error) {
      final index = myBlocks.getBlockIndex(memberId);
      myBlocks.updateBlock(index, block, isBlocked);
      print(error);
    });
  }
}

class MessagesRouteArguments {
  MessagesRouteArguments({this.chat});

  final ChatModel chat;
}
