import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:minsk8/import.dart';

class MapReadyButton extends StatefulWidget {
  MapReadyButton({
    this.center,
    this.zoom,
    this.radius,
    @required this.saveModes,
  }) : assert(saveModes != null);

  final LatLng center;
  final double zoom;
  final int radius;
  final List<MapSaveMode> saveModes;

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
      child: SizedBox(
        height: kBigButtonHeight,
        child: ReadyButton(onTap: _onTap, isRaised: true),
      ),
    );
  }

  void _onTap() {
    final center = widget.center;
    final zoom = widget.zoom;
    final radius = widget.radius;
    final saveModes = widget.saveModes;
    var isLoading = true;
    showDialog(
      context: context,
      barrierDismissible: false, // TODO: как отменить загрузку?
      child: AlertDialog(
        content: Row(
          children: <Widget>[
            ExtendedProgressIndicator(),
            SizedBox(width: 16),
            Text('Загрузка...'),
          ],
        ),
      ),
    );
    MapWidget.placemarkFromCoordinates(center).then((MapAddress value) {
      isLoading = false;
      navigator.pop(); // for showDialog "Загрузка..."
      if (saveModes.contains(MapSaveMode.showcase)) {
        appState['ShowcaseMap.center'] = [center.latitude, center.longitude];
        appState['ShowcaseMap.address'] = value.simple;
        appState['ShowcaseMap.zoom'] = zoom;
        appState['ShowcaseMap.radius'] = radius;
      }
      if (saveModes.contains(MapSaveMode.myUnit)) {
        appState['MyUnitMap.center'] = [center.latitude, center.longitude];
        appState['MyUnitMap.address'] = value.detail;
        appState['MyUnitMap.zoom'] = zoom;
      }
      navigator.pop(true);
    }).catchError((error) {
      out(error);
      if (isLoading) {
        navigator.pop(); // for showDialog "Загрузка..."
      }
      final snackBar = SnackBar(
          content: Text('Не удалось определить адрес, попробуйте ещё раз'));
      Scaffold.of(context).showSnackBar(snackBar);
    });
  }
}
