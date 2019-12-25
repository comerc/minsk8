import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

Widget buildPrice(TuChongItem item) {
  return Tooltip(
    message: 'Price',
    child: Material(
      child: InkWell(
        borderRadius: BorderRadius.all(kImageBorderRadius),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 16.3,
          ),
          child: Text(
            '\$99.99',
            style: TextStyle(
              fontSize: kFontSize * 1.6,
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: _onTap(item),
      ),
    ),
  );
}

Function _onTap(TuChongItem item) => () {};
