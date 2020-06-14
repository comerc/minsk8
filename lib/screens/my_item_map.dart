import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

// TODO: arguments и параметры в onWillPop - это всё лишнее;
// можно применить Provider, или тупо глобальную переменную, как appState

class MyItemMapScreen extends StatefulWidget {
  MyItemMapScreen(this.arguments);

  final MyItemMapRouteArguments arguments;

  @override
  _MyItemMapScreenState createState() {
    return _MyItemMapScreenState();
  }
}

class _MyItemMapScreenState extends State<MyItemMapScreen> {
  // LatLng center;
  // double zoom;
  bool _isPostFrame = false;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _isPostFrame = true);
  }

  @override
  void dispose() {
    _disposeTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = MapWidget(
      // center: center ?? widget.arguments.center,
      center: widget.arguments.center,
      zoom: 13.0, // zoom ?? widget.arguments.zoom,
      isItem: true,
      onPositionChanged: _onPositionChanged,
    );
    // return WillPopScope(
    //   onWillPop: _onWillPop,
    //   child: Scaffold(
    //     appBar: AppBar(
    //       title: Text('Местоположение'),
    //     ),
    //     body: body,
    //   ),
    // );
    return Scaffold(
      appBar: AppBar(
        title: Text('Местоположение'),
      ),
      body: body,
    );
  }

  _disposeTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onPositionChanged(MapPosition position, _) {
    // center = LatLng(
    //   position.center.latitude,
    //   position.center.longitude,
    // );
    // zoom = position.zoom;
    if (_isPostFrame) {
      final itemMap = Provider.of<ItemMapModel>(context, listen: false);
      if (itemMap.visible) {
        itemMap.hide();
      }
      _disposeTimer();
      _timer = Timer(Duration(milliseconds: kAnimationTime), () {
        if (_timer == null) return;
        _timer = null;
        _request(position.center).then((value) {
          final itemMap = Provider.of<ItemMapModel>(context, listen: false);
          itemMap.show(value);
        });
      });
    }
  }

  Future<String> _request(LatLng center) async {
    String result = '(none)';
    try {
      List<Placemark> placemarks = await Geolocator().placemarkFromCoordinates(
          center.latitude, center.longitude,
          localeIdentifier: 'ru');
      final placemark = placemarks[0];
      if (placemark.locality != '') {
        result = placemark.locality;
      } else if (placemark.subAdministrativeArea != '') {
        result = placemark.subAdministrativeArea;
      } else if (placemark.administrativeArea != '') {
        result = placemark.administrativeArea;
      } else if (placemark.country != '') {
        result = placemark.country;
      }
      if (placemark.thoroughfare != '') {
        result = result + ', ' + placemark.thoroughfare;
      } else if (placemark.name != '' && placemark.name != result) {
        result = result + ', ' + placemark.name;
      }
    } catch (e) {
      debugPrint('$e');
    }
    return result;
  }

  // Future<bool> _onWillPop() async {
  //   print('_onWillPop');
  //   return widget.arguments.onWillPop(center: center, zoom: zoom);
  // }
}

// typedef WillPopMyItemMapCallback = Future<bool> Function({
//   LatLng center,
//   // double zoom,
// });

class MyItemMapRouteArguments {
  MyItemMapRouteArguments({
    this.center,
    // this.zoom,
    // this.onWillPop
  });

  final LatLng center;
  // final double zoom;
  // final WillPopMyItemMapCallback onWillPop;
}
