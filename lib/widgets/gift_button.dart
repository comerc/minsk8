import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class GiftButton extends StatelessWidget {
  GiftButton(this.unit);

  final UnitModel unit;

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
            child: Logo(size: kButtonIconSize),
          ),
          onTap: () {
            showDialog(
              context: context,
              child: InfoDialog(
                title: 'Заберите лот даром, если\nне будет других желающих',
                description:
                    'Нажмите "хочу забрать",\n дождитесь окончания таймера',
              ),
            );
          },
        ),
      ),
    );
  }
}
