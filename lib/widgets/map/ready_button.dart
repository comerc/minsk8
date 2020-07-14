import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:minsk8/import.dart';

class MapReadyButton extends StatefulWidget {
  MapReadyButton({this.center, this.zoom});

  final LatLng center;
  final double zoom;

  @override
  _MapReadyButtonState createState() {
    return _MapReadyButtonState();
  }
}

class _MapReadyButtonState extends State<MapReadyButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Container(
        height: kBigButtonHeight,
        child: ReadyButton(onTap: _onTap, isRaised: true),
      ),
    );
  }

  _onTap() {
    final center = widget.center;
    appState['center'] = [center.latitude, center.longitude];
    appState['zoom'] = widget.zoom;
    MapWidget.placemarkFromCoordinates(center).then((value) {
      appState['address'] = value;
      Navigator.of(context).pop(true);
    });
  }
}
