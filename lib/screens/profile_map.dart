import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:minsk8/import.dart';

class ProfileMapScreen extends StatefulWidget {
  ProfileMapScreen(this.arguments);

  final ProfileMapRouteArguments arguments;

  @override
  ProfileMapScreenState createState() {
    return ProfileMapScreenState();
  }
}

class ProfileMapScreenState extends State<ProfileMapScreen> {
  bool _isShowcaseOnly;
  bool _isInfo;

  @override
  void initState() {
    super.initState();
    _isShowcaseOnly = widget.arguments?.isShowcaseOnly ?? false;
    _isInfo = !_isShowcaseOnly;
    print(_isInfo);
  }

  @override
  Widget build(context) {
    // if (appState['ProfileMap.isInitialized']) {
    // if (true) {
    //   Navigator.of(context).pop();
    //   return Container();
    // }
    Widget body = MapWidget(
      center: appState['ProfileMap.center'] == null
          ? LatLng(
              kDefaultMapCenter[0],
              kDefaultMapCenter[1],
            )
          : LatLng(
              appState['ProfileMap.center'][0],
              appState['ProfileMap.center'][1],
            ),
      zoom: appState['ProfileMap.zoom'] ?? 8,
      saveModes: _isShowcaseOnly
          ? [MapSaveMode.showcase]
          : [MapSaveMode.showcase, MapSaveMode.myItem],
    );
    if (_isInfo) {
      body = buildMapInfo(
        'Укажите желаемое местоположение, чтобы смотреть лоты поблизости',
        child: body,
        onClose: () {
          setState(() {
            _isInfo = false;
          });
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Map'),
      ),
      body: body,
    );
  }
}

class ProfileMapRouteArguments {
  ProfileMapRouteArguments({this.isShowcaseOnly = false});

  final bool isShowcaseOnly;
}
