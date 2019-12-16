import "package:flutter/material.dart";
import "package:transparent_image/transparent_image.dart";

class ShowcaseCard extends StatelessWidget {
  final item;

  ShowcaseCard(this.item);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white70,
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
                image: item['image']['url'][250],
                fit: BoxFit.cover,
                placeholder: kTransparentImage,
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/image',
                  arguments: item['image']['url'][1000],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
