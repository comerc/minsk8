import 'package:minsk8/import.dart';
import "package:transparent_image/transparent_image.dart";

class ShowcaseCard extends StatelessWidget {
  final int id;

  ShowcaseCard(this.id);

  @override
  Widget build(BuildContext context) {
    final item = items[id];
    return Card(
      color: Colors.white70,
      child: SizedBox(
        height: 250,
        child: Stack(
          children: [
            Center(
              child: CircularProgressIndicator(),
            ),
            Center(
              child: GestureDetector(
                child: FadeInImage.memoryNetwork(
                  width: 250.0,
                  height: 250.0,
                  image: item.imageUrl(250),
                  fit: BoxFit.cover,
                  placeholder: kTransparentImage,
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/item',
                    arguments: ItemRouteArguments(id),
                  );
                },
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
