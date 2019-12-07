import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import '../map_plugins/zoom.dart';
import '../map_plugins/area.dart';

// import '../widgets/drawer.dart';

class Home extends StatelessWidget {
  static const String route = '/';

  @override
  Widget build(BuildContext context) {
    var markers = <Marker>[
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(51.5, -0.09),
        builder: (ctx) => Container(
          child: FlutterLogo(
            colors: Colors.blue,
            key: ObjectKey(Colors.blue),
          ),
        ),
      ),
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(53.3498, -6.2603),
        builder: (ctx) => Container(
          child: FlutterLogo(
            colors: Colors.green,
            key: ObjectKey(Colors.green),
          ),
        ),
      ),
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(48.8566, 2.3522),
        builder: (ctx) => Container(
          child: FlutterLogo(
            colors: Colors.purple,
            key: ObjectKey(Colors.purple),
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      // drawer: buildDrawer(context, route),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(53.9, 27.56667),
          zoom: 8.0,
          minZoom: 4.0,
          plugins: [
            kReleaseMode ? null : ZoomPlugin(),
            AreaPlugin(),
          ].where((child) => child != null).toList(),
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: 'https://tilessputnik.ru/{z}/{x}/{y}.png',
            tileProvider: CachedNetworkTileProvider(),
          ),
          MarkerLayerOptions(markers: markers),
          kReleaseMode ? null : ZoomPluginOptions(),
          AreaPluginOptions(),
        ].where((child) => child != null).toList(),
      ),
    );
  }
}
