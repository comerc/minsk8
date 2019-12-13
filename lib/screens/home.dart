import 'package:flutter/material.dart';
import 'package:state_persistence/state_persistence.dart';
import './map.dart';
import './image_capture.dart';

// import '../widgets/drawer.dart';

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
            child: Text('Home'),
          ),
        );
      },
    );
  }
}
