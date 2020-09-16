import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
                final isBlocked = false;
                // ignore: unawaited_futures
                showDialog<String>(
                  context: context,
                  child: BlockDialog(
                    isBlocked: isBlocked,
                  ),
                ).then((String value) {
                  if (value == 'block') {}
                  if (value == 'unblock') {}
                  if (value == 'feedback') {
                    launchFeedback(
                      subject:
                          'Жалоба на победителя transactionId=${chat.transactionId}',
                      body: 'Здравствуйте! Столкнулся с проблемой ',
                    );
                  }
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
