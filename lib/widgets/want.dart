import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class Want extends StatelessWidget {
  Want(this.item);

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Want',
      child: Material(
        color: Colors.red,
        // borderRadius: BorderRadius.all(kImageBorderRadius),
        child: InkWell(
          splashColor: Colors.white,
          // borderRadius: BorderRadius.all(kImageBorderRadius),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              'ХОЧУ ЗАБРАТЬ',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: _onTap(item),
        ),
      ),
    );
  }

  Function _onTap(ItemModel item) => () {};
}
