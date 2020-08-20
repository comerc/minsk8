import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rainbow_color/rainbow_color.dart';
// import 'package:minsk8/import.dart';

Widget buildProgressIndicator(BuildContext context,
    {bool hasAnimatedColor = false}) {
  return Platform.isIOS
      ? CupertinoActivityIndicator(
          animating: true,
          radius: 16,
        )
      : hasAnimatedColor
          ? _AnimatedColorProgressIndicator()
          : CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor),
            );
}

class _AnimatedColorProgressIndicator extends StatefulWidget {
  @override
  _AnimatedColorProgressIndicatorState createState() =>
      _AnimatedColorProgressIndicatorState();
}

class _AnimatedColorProgressIndicatorState
    extends State<_AnimatedColorProgressIndicator>
    with SingleTickerProviderStateMixin {
  Animation<Color> _colorTween;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 4), vsync: this);
    _colorTween = _controller.drive(
      RainbowColorTween(
        [
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.red,
        ],
      ),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      strokeWidth: 2,
      valueColor: _colorTween,
    );
  }
}
