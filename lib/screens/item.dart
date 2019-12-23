import 'package:minsk8/import.dart';
import "package:transparent_image/transparent_image.dart";

// TODO: тут будет слайдер по картинкам одного товара

class ItemScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context).settings.arguments as ItemRouteArguments;
    final item = items[arguments.id];
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
                    arguments: ImagePinchRouteArguments(imageUrl),
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

class ItemRouteArguments {
  final int id;

  ItemRouteArguments(this.id);
}
