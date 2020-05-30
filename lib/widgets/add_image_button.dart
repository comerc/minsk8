import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:extended_image/extended_image.dart';
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
  final Uint8List image;

  // TODO: по длинному тапу - редактирование фотографии (кроп, поворот, и т.д.)

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Добавить/удалить фотографию',
      child: Material(
        child: InkWell(
          child: hasIcon
              ? Icon(
                  FontAwesomeIcons.camera,
                  color: Colors.black.withOpacity(0.8),
                  size: kBigButtonIconSize,
                )
              : image == null
                  ? Container()
                  : ExtendedImage.memory(image, fit: BoxFit.cover),
          onTap: _onTap,
        ),
      ),
    );
  }

  _onTap() {
    onTap(index);
  }
}
