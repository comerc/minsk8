import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:state_persistence/state_persistence.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import '../map_plugins/area_layer.dart';
import '../map_plugins/scale_layer.dart';
import '../map_plugins/zoom_layer.dart';

// import '../widgets/drawer.dart';

class Home extends StatelessWidget {
  static const String route = '/';

  @override
  Widget build(BuildContext context) {
    // final appState = PersistedAppState.of(context);

    // var markers = <Marker>[
    //   Marker(
    //     width: 80.0,
    //     height: 80.0,
    //     point: LatLng(51.5, -0.09),
    //     builder: (ctx) => Container(
    //       child: FlutterLogo(
    //         colors: Colors.blue,
    //         key: ObjectKey(Colors.blue),
    //       ),
    //     ),
    //   ),
    //   Marker(
    //     width: 80.0,
    //     height: 80.0,
    //     point: LatLng(53.3498, -6.2603),
    //     builder: (ctx) => Container(
    //       child: FlutterLogo(
    //         colors: Colors.green,
    //         key: ObjectKey(Colors.green),
    //       ),
    //     ),
    //   ),
    //   Marker(
    //     width: 80.0,
    //     height: 80.0,
    //     point: LatLng(48.8566, 2.3522),
    //     builder: (ctx) => Container(
    //       child: FlutterLogo(
    //         colors: Colors.purple,
    //         key: ObjectKey(Colors.purple),
    //       ),
    //     ),
    //   ),
    // ];

    return PersistedStateBuilder(
      builder: (BuildContext context, AsyncSnapshot<PersistedData> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            alignment: Alignment.center,
            color: Colors.white,
            child: CircularProgressIndicator(),
          );
        }
        final appState = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            title: Text('Home'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  PermissionHandler().openAppSettings().then((bool hasOpened) =>
                      debugPrint(
                          'App Settings opened: ' + hasOpened.toString()));
                },
              )
            ],
          ),
          // drawer: buildDrawer(context, route),
          body: FlutterMap(
            options: MapOptions(
              center: LatLng(appState['center.latitude'] ?? 53.9,
                  appState['center.longitude'] ?? 27.56667),
              zoom: appState['zoom'] ?? 8.0,
              minZoom: 4.0,
              onPositionChanged: (position, _hasGesture) {
                appState['center.latitude'] = position.center.latitude;
                appState['center.longitude'] = position.center.longitude;
                appState['zoom'] = position.zoom;
              },
              plugins: [
                AreaLayerPlugin(),
                kReleaseMode ? null : ScaleLayerPlugin(),
                kReleaseMode ? null : ZoomLayerPlugin(),
              ].where((child) => child != null).toList(),
            ),
            layers: [
              TileLayerOptions(
                urlTemplate: 'https://tilessputnik.ru/{z}/{x}/{y}.png',
                tileProvider: CachedNetworkTileProvider(),
              ),
              // MarkerLayerOptions(markers: markers),
              AreaLayerPluginOptions(),
              kReleaseMode
                  ? null
                  : ScaleLayerPluginOption(
                      lineColor: Colors.blue,
                      lineWidth: 2,
                      textStyle: TextStyle(color: Colors.blue, fontSize: 12),
                      padding: EdgeInsets.all(10),
                    ),
              kReleaseMode ? null : ZoomLayerPluginOptions(),
            ].where((child) => child != null).toList(),
          ),
        );
      },
    );
  }
}
