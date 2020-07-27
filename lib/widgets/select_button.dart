import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class SelectButton extends StatelessWidget {
  SelectButton({this.tooltip, this.text, this.rightText, this.onTap});

  final String tooltip;
  final String text;
  final String rightText;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        child: InkWell(
          child: Row(
            children: [
              SizedBox(width: 16),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(text),
              ),
              Spacer(),
              if (rightText != null) Text(rightText),
              SizedBox(width: 16),
              Icon(
                Icons.navigate_next,
                color: Colors.black.withOpacity(0.3),
                size: kButtonIconSize,
              ),
              SizedBox(width: 16),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
