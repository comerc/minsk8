import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minsk8/import.dart';

class Logo extends StatelessWidget {
  Logo({this.size = kLogoSize, this.hasShaderMask = true});

  final double size;
  final bool hasShaderMask;

  @override
  Widget build(BuildContext context) {
    Widget result = Icon(
      FontAwesomeIcons.gift,
      color: Colors.white,
      size: size,
    );
    if (hasShaderMask) {
      result = ShaderMask(
        shaderCallback: (Rect bounds) {
          return RadialGradient(
            center: Alignment.topLeft,
            radius: 1,
            tileMode: TileMode.mirror,
            colors: [Colors.yellow, Colors.deepOrange],
          ).createShader(bounds);
        },
        child: result,
      );
    }
    return result;
  }
}
