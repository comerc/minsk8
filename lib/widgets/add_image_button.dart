import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minsk8/import.dart';

class AddImageButton extends StatelessWidget {
  AddImageButton({this.hasIcon, this.onTap});

  final bool hasIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Добавить фотографию',
      child: Material(
        child: InkWell(
          child: hasIcon
              ? Icon(
                  FontAwesomeIcons.camera,
                  color: Colors.black.withOpacity(0.8),
                  size: kBigButtonIconSize,
                )
              : Container(),
          onTap: onTap,
        ),
      ),
    );
  }
}
