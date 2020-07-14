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
  bool _isPlaces = false;
  final _formFieldKey = GlobalKey<FormFieldState>();
  final _mapKey = GlobalKey<MapWidgetState>();

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
      key: _mapKey,
      center: appState['MyItemMap.center'] == null
          ? LatLng(
              kDefaultMapCenter[0],
              kDefaultMapCenter[1],
            )
          : LatLng(
              appState['MyItemMap.center'][0],
              appState['MyItemMap.center'][1],
            ),
      zoom: appState['MyItemMap.zoom'] ?? 8.0,
      isMyItem: true,
      onPositionChanged: _onPositionChanged,
    );
    return Scaffold(
      appBar: _isPlaces
          ? AppBar(
              backgroundColor: Colors.white,
              leading: IconButton(
                tooltip: 'Назад',
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black.withOpacity(0.8),
                ),
                onPressed: () {
                  setState(() {
                    _isPlaces = false;
                  });
                },
              ),
              title: Places(
                  formFieldKey: _formFieldKey,
                  onSuggestionSelected: _onSuggestionSelected),
              actions: [
                IconButton(
                  tooltip: 'Отменить',
                  icon: Icon(
                    Icons.close,
                    color: Colors.black.withOpacity(0.8),
                  ),
                  onPressed: () {
                    _formFieldKey.currentState.reset();
                  },
                )
              ],
            )
          : AppBar(
              title: Text('Местоположение'),
              actions: [
                IconButton(
                  tooltip: 'Искать',
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isPlaces = true;
                    });
                  },
                ),
              ],
            ),
      body: body,
      resizeToAvoidBottomInset: false,
    );
  }

  _disposeTimer() {
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

  _onSuggestionSelected(suggestion) {
    _mapKey.currentState.animatedMapMove(
      destCenter: LatLng(
        suggestion['_geoloc']['lat'],
        suggestion['_geoloc']['lng'],
      ),
      destZoom: 13,
    );
    setState(() {
      _isPlaces = false;
    });
  }
}
