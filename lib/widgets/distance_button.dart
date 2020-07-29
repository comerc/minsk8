import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

class DistanceButton extends StatelessWidget {
  DistanceButton({this.onTap});

  final Function onTap;

  @override
  Widget build(BuildContext context) {
    final distance = Provider.of<DistanceModel>(context);
    if (distance.value == null) {
      return Container();
    }
    final icon = Icons.location_on;
    final iconSize = 16.0;
    Widget text = RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <InlineSpan>[
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
            style: DefaultTextStyle.of(context).style.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.8),
                ),
            text: distance.value,
          ),
        ],
      ),
    );
    return Tooltip(
      message: 'Distance',
      child: Material(
        color: Colors.white,
        child: InkWell(
          child: Container(
            height: kButtonHeight,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: text,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
