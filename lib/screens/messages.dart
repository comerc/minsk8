import 'package:flutter/material.dart';
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
    final unit = widget.arguments.unit;
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
      ),
      body: SafeArea(child: body),
    );
  }
}

class MessagesRouteArguments {
  MessagesRouteArguments({this.unit});

  final UnitModel unit;
}
