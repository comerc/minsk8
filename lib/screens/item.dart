import "package:flutter/material.dart";
import "package:transparent_image/transparent_image.dart";
import '../const/fake_data.dart' show items;

// TODO: тут будет слайдер по картинкам одного товара

class ItemScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final itemIndex = ModalRoute.of(context).settings.arguments;
    final item = items[itemIndex];
    final imageUrl = item.imageUrl(1000);
    return Scaffold(
      appBar: AppBar(
        title: Text('Item ${item.name}'),
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
                    arguments: imageUrl,
                  );
                },
                child: FadeInImage.memoryNetwork(
                  image: imageUrl,
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
