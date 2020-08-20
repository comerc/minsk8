import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

class MyUnitMapScreen extends StatefulWidget {
  @override
  _MyUnitMapScreenState createState() {
    return _MyUnitMapScreenState();
  }
}

class _MyUnitMapScreenState extends State<MyUnitMapScreen> {
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
    Widget child = MapWidget(
      center: LatLng(
        appState['MyUnitMap.center'][0] as double,
        appState['MyUnitMap.center'][1] as double,
      ),
      zoom: appState['MyUnitMap.zoom'] as double,
      isMyUnit: true,
      onPositionChanged: _onPositionChanged,
    );
    if (appState['MyUnitMap.isInfo'] as bool ?? true) {
      child = MapInfo(
        text:
            'Укажите местоположение лота, чтобы участники поблизости его увидели',
        child: child,
        onClose: () {
          appState['MyUnitMap.isInfo'] = false;
          setState(() {});
        },
      );
    }
    return Scaffold(
      appBar: PlacesAppBar(),
      body: SafeArea(child: child),
      resizeToAvoidBottomInset: false,
    );
  }

  void _disposeTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onPositionChanged(MapPosition position, bool hasGesture) {
    if (!_isPostFrame) return;
    final myUnitMap = Provider.of<MyUnitMapModel>(context, listen: false);
    if (myUnitMap.visible) {
      myUnitMap.hide();
    }
    _disposeTimer();
    _timer = Timer(Duration(milliseconds: kAnimationTime), () {
      if (_timer == null) return;
      _timer = null;
      MapWidget.placemarkFromCoordinates(position.center)
          .then((MapAddress value) {
        myUnitMap.show(value.detail);
      });
    });
  }
}
