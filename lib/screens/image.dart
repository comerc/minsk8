import "package:flutter/material.dart";
import "package:transparent_image/transparent_image.dart";

class ImageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String url = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Image'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/image_pinch',
                    arguments: url,
                  );
                },
                child: FadeInImage.memoryNetwork(
                  image: url,
                  placeholder: kTransparentImage,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
