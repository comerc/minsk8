import 'package:flutter/material.dart';
import "package:pinch_zoom_image/pinch_zoom_image.dart";
import "package:transparent_image/transparent_image.dart";
import 'package:minsk8/import.dart';

class ImagePinchRouteArguments {
  final String imageUrl;

  ImagePinchRouteArguments(this.imageUrl);
}

class ImagePinchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context).settings.arguments as ImagePinchRouteArguments;
    return SafeArea(
      child: GestureDetector(
        child: PinchZoomImage(
          image: FadeInImage.memoryNetwork(
            image: arguments.imageUrl,
            placeholder: kTransparentImage,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
