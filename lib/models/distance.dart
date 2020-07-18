import 'package:flutter/foundation.dart';
import 'package:latlong/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:minsk8/import.dart';

class DistanceModel extends ChangeNotifier {
  String get value => _value;
  String _value;

  void updateValue(LatLng location) async {
    _value = null;
    if (appState['currentPosition'] == null) {
      return;
    }
    final distanceInMeters = await Geolocator().distanceBetween(
        appState['currentPosition'][0],
        appState['currentPosition'][1],
        location.latitude,
        location.longitude);
    _value = _formatValue(distanceInMeters);
  }

  String _formatValue(double distanceInMeters) {
    return '${(distanceInMeters / 1000).toStringAsFixed(distanceInMeters < 10000 ? 1 : 0)} км';
  }

  void updateCurrentPosition(LatLng location) async {
    final geolocationStatus =
        await Geolocator().checkGeolocationPermissionStatus();
    if (GeolocationStatus.granted == geolocationStatus) {
      try {
        final position = await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
        final oldCurrentPosition = appState['currentPosition'];
        appState['currentPosition'] = [position.latitude, position.longitude];
        if (oldCurrentPosition != null &&
            oldCurrentPosition[0] == appState['currentPosition'][0] &&
            oldCurrentPosition[1] == appState['currentPosition'][1]) {
          return;
        }
        updateValue(location);
      } catch (error) {
        debugPrint(error.toString());
      }
    }
  }
}
