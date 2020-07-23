import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
// import 'package:minsk8/import.dart';

// TODO: как сделать splash для элемента списка WalletScreen и пункта меню UnitScreen?

class Avatar extends StatelessWidget {
  Avatar(this.url, {this.radius = 20, this.elevation = 0, this.child});

  final String url;
  final double radius;
  final double elevation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      child: Material(
        elevation: elevation,
        type: MaterialType.circle,
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        child: Ink.image(
          fit: BoxFit.cover,
          image: ExtendedImage.network(
            url,
            enableLoadState: false,
          ).image,
          child: child,
        ),
      ),
    );
  }
}
