import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class MapInfo extends StatelessWidget {
  MapInfo({this.text, this.child, this.onClose});

  final String text;
  final Widget child;
  final Function onClose;

  @override
  Widget build(context) {
    const closeIconSize = 20.0;
    return Stack(
      children: [
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
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blueAccent,
                      size: kButtonIconSize,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: kButtonIconSize + 8,
                        right: closeIconSize,
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
                child: Icon(
                  Icons.close,
                  color: Colors.black.withOpacity(0.8),
                  size: closeIconSize,
                ),
                onTap: onClose,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
