import 'package:minsk8/import.dart';

class MessagesScreen extends StatefulWidget {
  MessagesScreen({this.chat});

  final ChatModel chat;

  @override
  _MessagesScreenState createState() {
    return _MessagesScreenState();
  }
}

class _MessagesScreenState extends State<MessagesScreen> {
  TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final unit = chat.unit;
    final avatar = Avatar(unit.avatarUrl);

    // final memberId = getMemberId(context);
    // final chat = widget.chat;
    // final                     (chat.unit.member.id == memberId
    //                         ? item.unitOwnerReadCount
    //                         : item.companionReadCount);

    final companion = chat.companion;
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: CustomScrollView(
            // anchor: 0.5,
            reverse: true,
            // floatHeaderSlivers: true,
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate(
                  List.generate(
                    3,
                    (index) => Container(
                      height: 100,
                      child: Text('$index'),
                      color: Colors.lightBlue[100 * (index % 9)],
                    ),
                  ),
                ),
              ),
              // TODO: прикреплять блок сверху
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Договоритесь о встрече',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ),
                      SizedBox(height: 8),
                      Divider(),
                      // TODO: [MVP] переход на страницу участника
                      ListTile(
                        leading: Avatar(companion.avatarUrl),
                        title: Text(companion.displayName),
                        subtitle: Text(
                          DateFormat.yMMMMd('ru_RU').format(
                            companion.lastActivityAt,
                          ),
                        ), // TODO: [MVP] 'Был 8 часов назад'
                        // dense: true,
                      ),
                      Divider(),
                      SizedBox(height: 8),
                      Content(filename: 'make_an_appointment.md'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1),
        Container(
          color: Colors.white,
          // child: Text(widget.chat.unit.id),
          child: TextField(
            enableSuggestions: false,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: _textController,
            // focusNode: _textFocusNode,
            decoration: InputDecoration(
              hintText: 'Напишите сообщение...',
              contentPadding: EdgeInsets.all(16),
              // TODO: Vertical Alignment https://github.com/flutter/flutter/issues/42651
              suffixIcon: ClipRRect(
                borderRadius: BorderRadius.circular(kDefaultIconSize),
                child: Material(
                  color: Colors.white,
                  child: InkWell(
                    // TODO: в телеге onLongPress > menu > "отправить позже", "отправить без звука"
                    onLongPress:
                        () {}, // без этой заглушки показывает системное меню "paste"
                    onTap: () {},
                    child: Icon(
                      Icons.send,
                      size: kDefaultIconSize,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
    return Scaffold(
      appBar: ExtendedAppBar(
        title: Tooltip(
          message: 'Go To Unit',
          // TODO: отсутствует InkWell - что с этим делать?
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                buildRoute(
                  '/unit',
                  builder: (_) => UnitScreen(
                    unit,
                    member: unit.member,
                  ),
                  fullscreenDialog: true,
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
                  child: _BlockDialog(isBlocked),
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
      body: SafeArea(
        child: child,
      ),
    );
  }
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

// class BlockDialog extends StatefulWidget {
//   @override
//   BlockDialogState createState() {
//     return BlockDialogState();
//   }
// }

// class BlockDialogState extends State<BlockDialog> {
//   @override
//   void initState() {
//     super.initState();
//     analytics.setCurrentScreen(screenName: '/block_dialog');
//   }
class _BlockDialog extends StatelessWidget {
  _BlockDialog(this.isBlocked);

  final bool isBlocked;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: <Widget>[
        Container(
          constraints: BoxConstraints(
            maxWidth: 200,
          ),
          child: Text(
            'Если победитель повёл себя некорректно\u00A0— заблокируйте его, чтобы он больше не\u00A0мог делать ставки на\u00A0Ваши\u00A0лоты. В\u00A0случае крайней необходимости\u00A0— напишите в\u00A0службу\u00A0поддержки.',
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 8,
        ),
        FlatButton(
          child: Text(isBlocked
              ? 'Разблокировать участника'
              : 'Заблокировать участника'),
          onLongPress: () {}, // чтобы сократить время для splashColor
          onPressed: () {
            Navigator.of(context).pop(isBlocked ? 'unblock' : 'block');
          },
          color: Colors.green,
          textColor: Colors.white,
        ),
        OutlineButton(
          child: Text('Написать в поддержку'),
          onLongPress: () {}, // чтобы сократить время для splashColor
          onPressed: () {
            Navigator.of(context).pop('feedback');
          },
          textColor: Colors.green,
        ),
      ],
    );
  }
}
