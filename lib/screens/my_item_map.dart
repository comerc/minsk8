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
  final _center = appState['center'] == null
      ? LatLng(
          kDefaultMapCenter[0],
          kDefaultMapCenter[1],
        )
      : LatLng(
          appState['center'][0],
          appState['center'][1],
        );
  final _zoom = appState['zoom'] ?? 8.0;

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
      center: _center,
      zoom: _zoom,
      isItem: true,
      onPositionChanged: _onPositionChanged,
    );
    return Scaffold(
      appBar: _isPlaces
          ? AppBar(
              backgroundColor: Colors.white,
              leading: IconButton(
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
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isPlaces = true;
                    });
                  },
                )
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

  void _onPositionChanged(MapPosition position, _) {
    if (_isPostFrame) {
      final itemMap = Provider.of<ItemMapModel>(context, listen: false);
      if (itemMap.visible) {
        itemMap.hide();
      }
      _disposeTimer();
      _timer = Timer(Duration(milliseconds: kAnimationTime), () {
        if (_timer == null) return;
        _timer = null;
        placemarkFromCoordinates(position.center).then((value) {
          final itemMap = Provider.of<ItemMapModel>(context, listen: false);
          itemMap.show(value);
        });
      });
    }
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
