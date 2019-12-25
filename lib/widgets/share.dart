import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

Widget buildShare(TuChongItem item) {
  return Tooltip(
    message: 'Share',
    child: Material(
      child: InkWell(
        borderRadius: BorderRadius.all(kImageBorderRadius),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 16.3,
          ),
          child: Icon(
            Icons.share,
            color: Colors.grey,
            size: 18.0,
          ),
        ),
        onTap: _onTap(item),
      ),
    ),
  );
}

Function _onTap(TuChongItem item) => () {};
