import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:minsk8/import.dart';

class MapReadyButton extends StatefulWidget {
  MapReadyButton({
    this.center,
    this.zoom,
    this.saveModes,
  }) : assert(saveModes != null);

  final LatLng center;
  final double zoom;
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
      child: Container(
        height: kBigButtonHeight,
        child: ReadyButton(onTap: _onTap, isRaised: true),
      ),
    );
  }

  _onTap() {
    final center = widget.center;
    final zoom = widget.zoom;
    final saveModes = widget.saveModes;
    bool isLoading = true;
    showDialog(
      context: context,
      barrierDismissible: false, // TODO: как отменить загрузку?
      child: AlertDialog(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildProgressIndicator(context),
            SizedBox(width: 16),
            Text('Загрузка...'),
          ],
        ),
      ),
    );
    MapWidget.placemarkFromCoordinates(center).then((MapAddress value) {
      isLoading = false;
      Navigator.of(context).pop(); // for showDialog "Загрузка..."
      if (saveModes.contains(MapSaveMode.showcase)) {
        appState['ProfileMap.center'] = [center.latitude, center.longitude];
        appState['ProfileMap.address'] = value.short;
        appState['ProfileMap.zoom'] = zoom;
      }
      if (saveModes.contains(MapSaveMode.myItem)) {
        appState['MyItemMap.center'] = [center.latitude, center.longitude];
        appState['MyItemMap.address'] = value.detail;
        appState['MyItemMap.zoom'] = zoom;
      }
      Navigator.of(context).pop(true);
    }).catchError((error) {
      debugPrint(error.toString());
      if (isLoading) {
        Navigator.of(context).pop(); // for showDialog "Загрузка..."
      }
      final snackBar = SnackBar(
          content: Text('Не удалось определить адрес, попробуйте ещё раз'));
      Scaffold.of(context).showSnackBar(snackBar);
    });
  }
}
