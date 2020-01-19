import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class Want extends StatelessWidget {
  Want(this.item, {this.isClosed});

  final ItemModel item;
  final bool isClosed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Want',
      child: Material(
        color: isClosed ? null : Colors.red,
        // borderRadius: BorderRadius.all(kImageBorderRadius),
        child: InkWell(
          splashColor: Colors.white,
          // borderRadius: BorderRadius.all(kImageBorderRadius),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              isClosed ? 'УЖЕ ЗАБРАЛИ' : 'ХОЧУ ЗАБРАТЬ',
              style: TextStyle(
                fontSize: 18,
                color: isClosed ? Colors.black.withOpacity(0.8) : Colors.white,
                fontWeight: FontWeight.w600,
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
