import 'package:flutter/material.dart';

class ExtendedListWheelScrollView extends StatelessWidget {
  ExtendedListWheelScrollView({
    Key key,
    @required this.builder,
    @required this.itemExtent,
    this.controller,
    this.onSelectedItemChanged,
    this.scrollDirection = Axis.vertical,
    this.diameterRatio = 2,
    this.useMagnifier = false,
    this.magnification = 1,
    this.minIndex,
    this.maxIndex,
  }) : super(key: key);

  final Widget Function(BuildContext, int) builder;
  final Axis scrollDirection;
  final FixedExtentScrollController controller;
  final double itemExtent;
  final double diameterRatio;
  final bool useMagnifier;
  final double magnification;
  final void Function(int) onSelectedItemChanged;
  final int minIndex;
  final int maxIndex;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: scrollDirection == Axis.horizontal ? 3 : 0,
      child: ListWheelScrollView.useDelegate(
        onSelectedItemChanged: onSelectedItemChanged,
        controller: controller,
        itemExtent: itemExtent,
        diameterRatio: diameterRatio,
        useMagnifier: useMagnifier,
        magnification: magnification,
        physics: FixedExtentScrollPhysics(),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (BuildContext context, int index) {
            if (minIndex != null && index < minIndex ||
                maxIndex != null && index > maxIndex) {
              return null;
            }
            return RotatedBox(
              quarterTurns: scrollDirection == Axis.horizontal ? 1 : 0,
              child: builder(context, index),
            );
          },
        ),
      ),
    );
  }
}
