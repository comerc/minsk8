import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:minsk8/import.dart';

class ShowcaseMapScreen extends StatelessWidget {
  @override
  Widget build(context) {
    Widget body = MapWidget(
      center: LatLng(
        appState['ShowcaseMap.center'][0],
        appState['ShowcaseMap.center'][1],
      ),
      zoom: appState['ShowcaseMap.zoom'],
      saveModes: <MapSaveMode>[MapSaveMode.showcase],
    );
    return Scaffold(
      appBar: PlacesAppBar(),
      body: body,
    );
  }
}
