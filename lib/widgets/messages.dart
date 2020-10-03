import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minsk8/import.dart';

class Messages extends StatefulWidget {
  Messages({this.chat});

  final ChatModel chat;

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
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
    // final memberId = getMemberId(context);
    // final chat = widget.chat;
    // final                     (chat.unit.member.id == memberId
    //                         ? item.unitOwnerReadCount
    //                         : item.companionReadCount);

    final companion = widget.chat.companion;
    return Column(
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
  }
}
