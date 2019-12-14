import 'package:flutter/material.dart';
import 'package:state_persistence/state_persistence.dart';
import "package:transparent_image/transparent_image.dart";
import './map.dart';
import './image_capture.dart';

// import '../widgets/drawer.dart';

const url = 'https://picsum.photos/250?image=9';

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
          body: Padding(
            padding: EdgeInsets.all(8.0),
            // child: InkWell(
            //   onTap: () {
            //     Navigator.of(context).pushNamed(
            //       '/image',
            //       arguments: url,
            //     );
            //   },
            child: Stack(
              children: <Widget>[
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                )),
                Center(
                  child: InkWell(
                      // tag: url, // TODO: Hero
                      child: FadeInImage.memoryNetwork(
                        image: url,
                        fit: BoxFit.cover,
                        placeholder: kTransparentImage,
                      ),
                      onTap: () {
                        return Navigator.pushNamed(
                          context,
                          '/image/pinch',
                          arguments: url,
                        );
                      }),
                ),
              ],
            ),
            // ),
          ),
        );
      },
    );
  }
}
