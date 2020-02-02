import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class SelectButton extends StatelessWidget {
  SelectButton({Key key, this.tooltip, this.text, this.onTap})
      : super(key: key);
  final String tooltip;
  final String text;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        child: InkWell(
          child: Row(
            children: [
              SizedBox(
                width: 16.0,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(text),
              ),
              Expanded(
                child: Container(),
              ),
              Icon(
                Icons.navigate_next,
                color: Colors.black.withOpacity(0.8),
                size: kButtonIconSize,
              ),
              SizedBox(
                width: 16.0,
              ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}