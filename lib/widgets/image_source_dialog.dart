import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minsk8/import.dart';

Future<ImageSource> showImageSourceDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text('Что использовать?'),
      children: [
        _ImageSourceUnit(
          icon: FontAwesomeIcons.camera,
          text: 'Камера',
          result: ImageSource.camera,
        ),
        _ImageSourceUnit(
          icon: FontAwesomeIcons.solidImages,
          text: 'Галерея',
          result: ImageSource.gallery,
        ),
      ],
    ),
  );
}

class _ImageSourceUnit extends StatelessWidget {
  _ImageSourceUnit({
    Key key,
    this.icon,
    this.text,
    this.result,
  }) : super(key: key);

  final IconData icon;
  final String text;
  final ImageSource result;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {}, // чтобы сократить время для splashColor
      child: SimpleDialogOption(
        onPressed: () {
          Navigator.of(context).pop(result);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.black.withOpacity(0.8),
              size: kBigButtonIconSize,
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsetsDirectional.only(start: 16),
                child: Text(text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
