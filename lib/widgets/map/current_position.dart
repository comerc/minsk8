import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:minsk8/import.dart';

typedef void MapCurrentPositionCallback(Position position);

class MapCurrentPosition extends StatefulWidget {
  MapCurrentPosition({this.onCurrentPosition});

  final MapCurrentPositionCallback onCurrentPosition;

  @override
  MapCurrentPositionState createState() {
    return MapCurrentPositionState();
  }
}

class MapCurrentPositionState extends State<MapCurrentPosition> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(bottom: 16),
      child: MaterialButton(
        color: Colors.white,
        child: Icon(Icons.my_location),
        height: kBigButtonHeight,
        shape: CircleBorder(),
        onPressed: _onCurrentPositionClick,
      ),
    );
  }

  Future<void> _onCurrentPositionClick() async {
    if (appState['isNeverAskAgain'] ?? false) {
      final geolocationStatus =
          await Geolocator().checkGeolocationPermissionStatus();
      if (GeolocationStatus.granted == geolocationStatus) {
        appState['isNeverAskAgain'] = false;
      } else {
        final isOK = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(
                "You need to allow access to device's location in Permissions from App Settings."),
            actions: [
              FlatButton(
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ],
          ),
        );
        if (isOK ?? false) {
          final permissionHandler = PermissionHandler();
          await permissionHandler.openAppSettings();
        }
        return;
      }
    }
    final isShown = await PermissionHandler()
        .shouldShowRequestPermissionRationale(PermissionGroup.location);
    try {
      final Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      widget.onCurrentPosition(position);
    } catch (error) {
      debugPrint(error.toString());
      if (isShown) {
        final isNeverAskAgain = !(await PermissionHandler()
            .shouldShowRequestPermissionRationale(PermissionGroup.location));
        if (isNeverAskAgain) {
          appState['isNeverAskAgain'] = true;
        }
      }
    }
  }
}
