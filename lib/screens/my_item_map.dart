import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:minsk8/import.dart';

class MyItemMapScreen extends StatefulWidget {
  MyItemMapScreen(this.arguments);

  final MyItemMapRouteArguments arguments;

  @override
  _MyItemMapScreenState createState() {
    return _MyItemMapScreenState();
  }
}

class _MyItemMapScreenState extends State<MyItemMapScreen> {
  LatLng center;
  double zoom;

  @override
  Widget build(BuildContext context) {
    final body = MapWidget(
      center: center ?? widget.arguments.center,
      zoom: zoom ?? widget.arguments.zoom,
      // TODO: centerWithMarkerPoint
      // markerPoint: center ?? widget.arguments.center,
      onPositionChanged: (position, _) {
        center = LatLng(
          position.center.latitude,
          position.center.longitude,
        );
        zoom = position.zoom;
      },
    );
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Местоположение'),
        ),
        body: body,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return widget.arguments.onWillPop(center: center, zoom: zoom);
  }
}

typedef WillPopMyItemMapCallback = Future<bool> Function({
  LatLng center,
  double zoom,
});

class MyItemMapRouteArguments {
  MyItemMapRouteArguments({this.center, this.zoom, this.onWillPop});

  final LatLng center;
  final double zoom;
  final WillPopMyItemMapCallback onWillPop;
}
