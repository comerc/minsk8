import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class Distance extends StatelessWidget {
  final icon = Icons.location_on;
  final iconSize = 16.0;

  Distance(this.value);

  final double value;

  @override
  Widget build(BuildContext context) {
    Widget text = RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          WidgetSpan(
            child: SizedBox(
              height: iconSize,
              child: RichText(
                text: TextSpan(
                  text: String.fromCharCode(icon.codePoint),
                  style: TextStyle(
                    fontSize: iconSize,
                    fontFamily: icon.fontFamily,
                    color: Colors.pinkAccent,
                  ),
                ),
              ),
            ),
          ),
          TextSpan(
            style: DefaultTextStyle.of(context)
                .style
                .copyWith(fontWeight: FontWeight.w600),
            text: '$value км',
          ),
        ],
      ),
    );
    return Tooltip(
      message: 'Distance',
      child: Material(
        child: InkWell(
          child: Container(
            height: kButtonHeight,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            child: text,
          ),
          onTap: _onTap,
        ),
      ),
    );
  }

  _onTap() {}
}
