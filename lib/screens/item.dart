import "package:flutter/material.dart";
import "package:transparent_image/transparent_image.dart";

// TODO: тут будет слайдер по картинкам одного товара

class ItemScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String url = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Item'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
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
