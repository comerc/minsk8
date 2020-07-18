import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

class MyItemMapScreen extends StatefulWidget {
  @override
  _MyItemMapScreenState createState() {
    return _MyItemMapScreenState();
  }
}

class _MyItemMapScreenState extends State<MyItemMapScreen> {
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
    Widget body = MapWidget(
      center: LatLng(
        appState['MyItemMap.center'][0],
        appState['MyItemMap.center'][1],
      ),
      zoom: appState['MyItemMap.zoom'],
      isMyItem: true,
      onPositionChanged: _onPositionChanged,
    );
    if (appState['MyItemMap.isInfo'] ?? true) {
      body = MapInfo(
        text:
            'Укажите местоположение лота, чтобы участники поблизости его увидели',
        child: body,
        onClose: () {
          appState['MyItemMap.isInfo'] = false;
          setState(() {});
        },
      );
    }
    return Scaffold(
      appBar: PlacesAppBar(),
      body: body,
      resizeToAvoidBottomInset: false,
    );
  }

  void _disposeTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onPositionChanged(MapPosition position, bool hasGesture) {
    if (!_isPostFrame) return;
    final myItemMap = Provider.of<MyItemMapModel>(context, listen: false);
    if (myItemMap.visible) {
      myItemMap.hide();
    }
    _disposeTimer();
    _timer = Timer(Duration(milliseconds: kAnimationTime), () {
      if (_timer == null) return;
      _timer = null;
      MapWidget.placemarkFromCoordinates(position.center)
          .then((MapAddress value) {
        myItemMap.show(value.detail);
      });
    });
  }
}
