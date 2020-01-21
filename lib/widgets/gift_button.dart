import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minsk8/import.dart';

class GiftButton extends StatelessWidget {
  GiftButton(this.item);

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Gift',
      child: Material(
        child: InkWell(
          // borderRadius: BorderRadius.all(kImageBorderRadius),
          child: Container(
            height: kButtonHeight,
            width: kButtonWidth,
            child: Icon(
              FontAwesomeIcons.gift,
              color: Colors.deepOrangeAccent,
              size: kButtonIconSize,
            ),
          ),
          onTap: () {},
        ),
      ),
    );
  }
}
