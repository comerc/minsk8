import "package:flutter/material.dart";
import "package:transparent_image/transparent_image.dart";
import '../const/fake_data.dart' show items;

class ShowcaseCard extends StatelessWidget {
  final itemIndex;

  ShowcaseCard(this.itemIndex);

  @override
  Widget build(BuildContext context) {
    final item = items[itemIndex];
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
                    arguments: itemIndex,
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
