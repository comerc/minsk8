import 'package:flutter/material.dart';
import 'package:state_persistence/state_persistence.dart';
import "package:transparent_image/transparent_image.dart";
import './map.dart';
import '../widgets/main_drawer.dart';

const url = {
  1000: 'https://picsum.photos/1000?image=9',
  250: 'https://picsum.photos/250?image=9'
};

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PersistedStateBuilder(
      builder: (BuildContext context, AsyncSnapshot<PersistedData> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            alignment: Alignment.center,
            color: Colors.white,
            child: CircularProgressIndicator(),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Home'),
            actions: [
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/image_capture');
                },
                tooltip: 'Tooltip', // TODO:
              ),
              IconButton(
                icon: const Icon(Icons.map),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/map');
                },
                tooltip: 'Tooltip', // TODO:
              ),
            ],
          ),
          drawer: MainDrawer('/'),
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
      },
    );
  }
}
