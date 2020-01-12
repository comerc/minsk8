import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
// import 'package:minsk8/import.dart';

class ItemImage extends StatelessWidget {
  final String url;
  final BoxFit fit;

  ItemImage(this.url, {this.fit});

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      url,
      fit: fit,
      // shape: BoxShape.rectangle,
      // border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.0),
      // borderRadius: BorderRadius.all(kImageBorderRadius),
      loadStateChanged: (state) {
        if (state.extendedImageLoadState != LoadState.loading) return null;
        return Container(
          alignment: Alignment.center,
          color: Colors.grey.withOpacity(0.3),
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
          ),
        );
      },
    );
  }
}
