import 'package:flutter/material.dart';

// ListView.separated() signature

class ListBox extends StatelessWidget {
  ListBox({
    @required this.itemBuilder,
    @required this.separatorBuilder,
    @required this.itemCount,
  });

  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder separatorBuilder;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount * 2 - 1,
        (index) {
          final itemIndex = index ~/ 2;
          Widget widget;
          if (index.isEven) {
            widget = itemBuilder(context, itemIndex);
          } else {
            widget = separatorBuilder(context, itemIndex);
            assert(() {
              if (widget == null) {
                throw FlutterError('separatorBuilder cannot return null.');
              }
              return true;
            }());
          }
          return widget;
        },
      ),
    );
  }
}
