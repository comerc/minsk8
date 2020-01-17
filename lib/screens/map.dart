import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../map_plugins/area_layer.dart';
import '../map_plugins/scale_layer.dart';
import '../map_plugins/zoom_layer.dart';
import 'package:minsk8/import.dart';

// import '../widgets/drawer.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() {
    return _MapScreenState();
  }
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  // Note the addition of the TickerProviderStateMixin here. If you are getting an error like
  // 'The class 'TickerProviderStateMixin' can't be used as a mixin because it extends a class other than Object.'
  // in your IDE, you can probably fix it by adding an analysis_options.yaml file to your project
  // with the following content:
  //  analyzer:
  //    language:
  //      enableSuperMixins: true
  // See https://github.com/flutter/flutter/issues/14317#issuecomment-361085869
  // This project didn't require that change, so YMMV.

  // LatLng _currentPosition;
  MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  void _animatedMapMove(LatLng destCenter, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(
        begin: _mapController.center.latitude, end: destCenter.latitude);
    final lngTween = Tween<double>(
        begin: _mapController.center.longitude, end: destCenter.longitude);
    final zoomTween = Tween<double>(begin: _mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
        actions: [
          if (isInDebugMode)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                PermissionHandler().openAppSettings().then((bool hasOpened) {
                  debugPrint('App Settings opened: $hasOpened');
                });
              },
            )
        ],
      ),
      drawer: MainDrawer('/map'),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: appState['center'] == null
              ? LatLng(
                  kDefaultMapCenter[0],
                  kDefaultMapCenter[1],
                )
              : LatLng(
                  appState['center'][0],
                  appState['center'][1],
                ),
          zoom: appState['zoom'] ?? 8.0,
          minZoom: 4.0,
          onPositionChanged: (position, _hasGesture) {
            appState['center'] = [
              position.center.latitude,
              position.center.longitude
            ];
            appState['zoom'] = position.zoom;
          },
          plugins: [
            AreaLayerMapPlugin(),
            if (isInDebugMode) ScaleLayerMapPlugin(),
            if (isInDebugMode) ZoomLayerMapPlugin(),
          ],
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: 'https://tilessputnik.ru/{z}/{x}/{y}.png',
            tileProvider: CachedNetworkTileProvider(),
          ),
          if (appState['currentPosition'] != null)
            CircleLayerOptions(circles: [
              CircleMarker(
                // useRadiusInMeter: true,
                radius: 4.0,
                color: Colors.blue,
                borderColor: Colors.black,
                borderStrokeWidth: 1.0,
                point: LatLng(
                  appState['currentPosition'][0],
                  appState['currentPosition'][1],
                ),
              ),
            ]),
          AreaLayerMapPluginOptions(
            getRadius: () => appState['radius'],
            onChangeRadius: (value) => appState['radius'] = value,
            onCurrentPositionClick: () async {
              if (appState['isNeverAskAgain'] ?? false) {
                final geolocationStatus =
                    await Geolocator().checkGeolocationPermissionStatus();
                if (GeolocationStatus.granted == geolocationStatus) {
                  appState['isNeverAskAgain'] = false;
                } else {
                  final isOK = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Text(
                          "You need to allow access to device's location in Permissions from App Settings."),
                      actions: [
                        FlatButton(
                          child: Text('CANCEL'),
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                        ),
                        FlatButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                        ),
                      ],
                    ),
                  );
                  if (isOK ?? false) {
                    final permissionHandler = PermissionHandler();
                    await permissionHandler.openAppSettings();
                  }
                  return;
                }
              }
              final isShown = await PermissionHandler()
                  .shouldShowRequestPermissionRationale(
                      PermissionGroup.location);
              try {
                final Position position = await Geolocator()
                    .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
                setState(() {
                  appState['currentPosition'] = [
                    position.latitude,
                    position.longitude
                  ];
                  // _currentPosition =
                  //     LatLng(position.latitude, position.longitude);
                  _animatedMapMove(
                      LatLng(position.latitude, position.longitude), 10.0);
                });
                // if (widget.options.onMoveToCurrentPosition == null) {
                //   widget.mapState.move(
                //       LatLng(position.latitude, position.longitude),
                //       widget.mapState.zoom);
                // } else {
                //   widget.options.onMoveToCurrentPosition(
                //       LatLng(position.latitude, position.longitude),
                //       widget.mapState.zoom);
                // }
              } catch (error) {
                debugPrint(error.toString());
                if (isShown) {
                  final isNeverAskAgain = !(await PermissionHandler()
                      .shouldShowRequestPermissionRationale(
                          PermissionGroup.location));
                  if (isNeverAskAgain) {
                    appState['isNeverAskAgain'] = true;
                  }
                }
              }
            },
            // onMoveToCurrentPosition: (destCenter, destZoom) {
            //   setState(() {
            //     _currentPosition = destCenter;
            //   });
            //   _animatedMapMove(destCenter, destZoom);
            // },
          ),
          if (isInDebugMode)
            ScaleLayerMapPluginOption(
              lineColor: Colors.blue,
              lineWidth: 2,
              textStyle: TextStyle(color: Colors.blue, fontSize: 12),
              padding: EdgeInsets.all(10),
            ),
          if (isInDebugMode) ZoomLayerMapPluginOptions(),
        ],
      ),
    );
  }
}
