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

class Map extends StatefulWidget {
  static const String route = '/map';

  @override
  MapState createState() {
    return MapState();
  }
}

class MapState extends State<Map> with TickerProviderStateMixin {
  // Note the addition of the TickerProviderStateMixin here. If you are getting an error like
  // 'The class 'TickerProviderStateMixin' can't be used as a mixin because it extends a class other than Object.'
  // in your IDE, you can probably fix it by adding an analysis_options.yaml file to your project
  // with the following content:
  //  analyzer:
  //    language:
  //      enableSuperMixins: true
  // See https://github.com/flutter/flutter/issues/14317#issuecomment-361085869
  // This project didn't require that change, so YMMV.

  MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  void _animatedMapMove(LatLng destCenter, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = Tween<double>(
        begin: mapController.center.latitude, end: destCenter.latitude);
    final _lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destCenter.longitude);
    final _zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
          LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
          _zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    // final appState = PersistedAppState.of(context);
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
            title: Text('Map'),
            actions: [
              kReleaseMode
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        PermissionHandler().openAppSettings().then(
                            (bool hasOpened) => debugPrint(
                                'App Settings opened: ' +
                                    hasOpened.toString()));
                      },
                    )
            ].where((child) => child != null).toList(),
          ),
          // drawer: buildDrawer(context, route),
          body: FlutterMap(
            mapController: mapController,
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
              AreaLayerPluginOptions(onMove: _animatedMapMove),
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
