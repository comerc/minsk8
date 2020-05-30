import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minsk8/import.dart';

typedef AddImageButtonOnTap = void Function(int index);

class AddImageButton extends StatelessWidget {
  AddImageButton({
    Key key,
    this.index,
    this.hasIcon,
    this.onTap,
    this.image,
  }) : super(key: key);

  final int index;
  final bool hasIcon;
  final AddImageButtonOnTap onTap;
  final Image image;

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
              : image == null ? Container() : image,
          onTap: _onTap,
        ),
      ),
    );
  }

  _onTap() {
    onTap(index);
  }
}
