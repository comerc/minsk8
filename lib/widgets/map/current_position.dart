import 'package:minsk8/import.dart';

typedef MapCurrentPositionCallback = void Function(Position position);

class MapCurrentPosition extends StatefulWidget {
  MapCurrentPosition({this.onCurrentPosition});

  final MapCurrentPositionCallback onCurrentPosition;

  @override
  _MapCurrentPositionState createState() {
    return _MapCurrentPositionState();
  }
}

class _MapCurrentPositionState extends State<MapCurrentPosition> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(bottom: 16),
      // Tooltip перекрывает onLongPress для FlutterMap
      child: Tooltip(
        message: 'Где я?',
        // TODO: FlatButton
        child: MaterialButton(
          color: Colors.white,
          height: kBigButtonHeight,
          shape: CircleBorder(),
          onPressed: _onCurrentPositionClick,
          child: Icon(
            Icons.my_location,
            size: kDefaultIconSize,
          ),
        ),
      ),
    );
  }

  Future<void> _onCurrentPositionClick() async {
    if (appState['isNeverAskAgain'] as bool ?? false) {
      final geolocationStatus =
          await Geolocator().checkGeolocationPermissionStatus();
      if (GeolocationStatus.granted == geolocationStatus) {
        appState['isNeverAskAgain'] = false;
      } else {
        final isOK = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(
                "You need to allow access to device's location in Permissions from App Settings."),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  navigator.pop(false);
                },
                child: Text('CANCEL'),
              ),
              FlatButton(
                onPressed: () {
                  navigator.pop(true);
                },
                child: Text('OK'),
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
      final position = await Geolocator().getCurrentPosition();
      widget.onCurrentPosition(position);
    } catch (error) {
      out(error);
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
