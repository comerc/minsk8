import 'package:flutter/material.dart';
import 'package:state_persistence/state_persistence.dart';
import "package:transparent_image/transparent_image.dart";
import './map.dart';
import './image_capture.dart';

// import '../widgets/drawer.dart';

const url = {
  1000: 'https://picsum.photos/1000?image=9',
  250: 'https://picsum.photos/250?image=9'
};

class HomeScreen extends StatelessWidget {
  static const String route = '/';

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
                  // Navigator.pushReplacementNamed(context, '/map');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ImageCapture()),
                  );
                },
                tooltip: 'Tooltip', // TODO:
              ),
              IconButton(
                icon: const Icon(Icons.map),
                onPressed: () {
                  // Navigator.pushReplacementNamed(context, '/map');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapScreen()),
                  );
                },
                tooltip: 'Tooltip', // TODO:
              ),
            ],
          ),
          // drawer: buildDrawer(context, route),
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
                    Navigator.pushNamed(
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
