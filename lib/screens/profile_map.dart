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
  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Map'),
      ),
      drawer: MainDrawer('/profile_map'),
      body: MapWidget(
        center: appState['center'] == null
            ? LatLng(
                kDefaultMapCenter[0],
                kDefaultMapCenter[1],
              )
            : LatLng(
                appState['center'][0],
                appState['center'][1],
              ),
        zoom: appState['zoom'] ?? 8,
        onPositionChanged: (position, _) {
          appState['center'] = [
            position.center.latitude,
            position.center.longitude
          ];
          appState['zoom'] = position.zoom;
        },
        initialRadius: appState['radius'],
        onChangeRadius: (value) {
          appState['radius'] = value;
        },
      ),
    );
  }
}
