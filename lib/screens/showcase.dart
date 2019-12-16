import 'package:flutter/material.dart';
import "package:transparent_image/transparent_image.dart";
import '../widgets/main_drawer.dart';

const url = {
  1000: 'https://picsum.photos/1000?image=9',
  250: 'https://picsum.photos/250?image=9'
};

class ShowcaseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Showcase'),
      ),
      drawer: MainDrawer('/showcase'),
      body: Stack(
        children: [
          Center(
            child: CircularProgressIndicator(),
          ),
          Center(
            child: GestureDetector(
              child: FadeInImage.memoryNetwork(
                width: 250.0,
                height: 250.0,
                image: url[250],
                fit: BoxFit.cover,
                placeholder: kTransparentImage,
              ),
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/image',
                  arguments: url[1000],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
