import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class MapInfo extends StatelessWidget {
  MapInfo({this.text, this.child, this.onClose});

  final String text;
  final Widget child;
  final void Function() onClose;

  @override
  Widget build(BuildContext context) {
    const kCloseIconSize = 20.0;
    return Stack(
      children: <Widget>[
        child,
        Positioned(
          top: 48,
          left: 16,
          right: 16,
          child: IgnorePointer(
            child: Material(
              elevation: kButtonElevation,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                color: Colors.white,
                child: Stack(
                  children: <Widget>[
                    Icon(
                      Icons.info_outline,
                      color: Colors.blueAccent,
                      size: kButtonIconSize,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: kButtonIconSize + 8,
                        right: kCloseIconSize,
                      ),
                      child: Text(text),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 48,
          right: 16,
          child: Tooltip(
            message: 'Закрыть',
            child: Material(
              child: InkWell(
                onTap: onClose,
                child: Icon(
                  Icons.close,
                  color: Colors.black.withOpacity(0.8),
                  size: kCloseIconSize,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
