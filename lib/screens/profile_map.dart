import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:minsk8/import.dart';

// class ProfileMapScreen extends StatefulWidget {
//   @override
//   ProfileMapScreenState createState() {
//     return ProfileMapScreenState();
//   }
// }

// class ProfileMapScreenState extends State<ProfileMapScreen> {
class ProfileMapScreen extends StatelessWidget {
  ProfileMapScreen(this.arguments);

  final ProfileMapRouteArguments arguments;

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Map'),
      ),
      body: MapWidget(
        center: appState['ProfileMap.center'] == null
            ? LatLng(
                kDefaultMapCenter[0],
                kDefaultMapCenter[1],
              )
            : LatLng(
                appState['ProfileMap.center'][0],
                appState['ProfileMap.center'][1],
              ),
        zoom: appState['ProfileMap.zoom'] ?? 8,
        saveModes: arguments.isShowcaseOnly
            ? [MapSaveMode.showcase]
            : [MapSaveMode.showcase, MapSaveMode.myItem],
      ),
    );
  }
}

class ProfileMapRouteArguments {
  ProfileMapRouteArguments({this.isShowcaseOnly = false});

  final bool isShowcaseOnly;
}
