import 'package:flutter/material.dart';
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
              SliverToBoxAdapter(
                child: Container(color: Colors.red, height: 200),
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
