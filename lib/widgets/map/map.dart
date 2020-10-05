import 'package:minsk8/import.dart';
import 'area_layer.dart';
import 'my_unit_layer.dart';
import 'scale_layer.dart';
import 'zoom_layer.dart';

// TODO: [MVP] добавить копирайт sputnik и osm

// TODO: убрать '(none)' - это для отображения, а для данных нужно вернуть null
// искать применение надо по appState['MyUnitMap.address'], и не допускать пустой строки
class MapAddress {
  String simple = '(none)';
  String detail = '(none)';
}

enum MapSaveMode { showcase, myUnit }

class MapWidget extends StatefulWidget {
  MapWidget({
    this.center,
    this.zoom,
    this.onPositionChanged,
    this.markerPoint,
    this.isMyUnit = false,
    this.saveModes,
  }) : super(key: globalKey);

  static final globalKey = GlobalKey<MapWidgetState>();

  final LatLng center;
  final double zoom;
  final PositionCallback onPositionChanged;
  final LatLng markerPoint;
  final bool isMyUnit;
  final List<MapSaveMode> saveModes;

  @override
  MapWidgetState createState() {
    return MapWidgetState();
  }

  static LatLng calculateEndingGlobalCoordinates(
      LatLng start, double startBearing, double distance) {
    const piOver180 = PI / 180.0;

    double toDegrees(double radians) {
      return radians / piOver180;
    }

    double toRadians(double degrees) {
      return degrees * piOver180;
    }

    final mSemiMajorAxis = 6378137.0; //WGS84 major axis
    final mSemiMinorAxis = (1.0 - 1.0 / 298.257223563) * 6378137.0;
    final mFlattening = 1.0 / 298.257223563;
    // double mInverseFlattening = 298.257223563;
    final a = mSemiMajorAxis;
    final b = mSemiMinorAxis;
    final aSquared = a * a;
    final bSquared = b * b;
    final f = mFlattening;
    final phi1 = toRadians(start.latitude);
    final alpha1 = toRadians(startBearing);
    final cosAlpha1 = cos(alpha1);
    final sinAlpha1 = sin(alpha1);
    final s = distance;
    final tanU1 = (1.0 - f) * tan(phi1);
    final cosU1 = 1.0 / sqrt(1.0 + tanU1 * tanU1);
    final sinU1 = tanU1 * cosU1;
    // eq. 1
    final sigma1 = atan2(tanU1, cosAlpha1);
    // eq. 2
    final sinAlpha = cosU1 * sinAlpha1;
    final sin2Alpha = sinAlpha * sinAlpha;
    final cos2Alpha = 1 - sin2Alpha;
    final uSquared = cos2Alpha * (aSquared - bSquared) / bSquared;
    // eq. 3
    final A = 1 +
        (uSquared / 16384) *
            (4096 + uSquared * (-768 + uSquared * (320 - 175 * uSquared)));
    // eq. 4
    final B = (uSquared / 1024) *
        (256 + uSquared * (-128 + uSquared * (74 - 47 * uSquared)));
    // iterate until there is a negligible change in sigma
    double deltaSigma;
    final sOverbA = s / (b * A);
    var sigma = sOverbA;
    double sinSigma;
    var prevSigma = sOverbA;
    double sigmaM2;
    double cosSigmaM2;
    double cos2SigmaM2;
    while (true) {
      // eq. 5
      sigmaM2 = 2.0 * sigma1 + sigma;
      cosSigmaM2 = cos(sigmaM2);
      cos2SigmaM2 = cosSigmaM2 * cosSigmaM2;
      sinSigma = sin(sigma);
      final cosSignma = cos(sigma);
      // eq. 6
      deltaSigma = B *
          sinSigma *
          (cosSigmaM2 +
              (B / 4.0) *
                  (cosSignma * (-1 + 2 * cos2SigmaM2) -
                      (B / 6.0) *
                          cosSigmaM2 *
                          (-3 + 4 * sinSigma * sinSigma) *
                          (-3 + 4 * cos2SigmaM2)));
      // eq. 7
      sigma = sOverbA + deltaSigma;
      // break after converging to tolerance
      if ((sigma - prevSigma).abs() < 0.0000000000001) break;
      prevSigma = sigma;
    }
    sigmaM2 = 2.0 * sigma1 + sigma;
    cosSigmaM2 = cos(sigmaM2);
    cos2SigmaM2 = cosSigmaM2 * cosSigmaM2;
    final cosSigma = cos(sigma);
    sinSigma = sin(sigma);
    // eq. 8
    final phi2 = atan2(
        sinU1 * cosSigma + cosU1 * sinSigma * cosAlpha1,
        (1.0 - f) *
            sqrt(sin2Alpha +
                pow(sinU1 * sinSigma - cosU1 * cosSigma * cosAlpha1, 2.0)));
    // eq. 9
    // This fixes the pole crossing defect spotted by Matt Feemster. When a
    // path passes a pole and essentially crosses a line of latitude twice -
    // once in each direction - the longitude calculation got messed up.
    // Using
    // atan2 instead of atan fixes the defect. The change is in the next 3
    // lines.
    // double tanLambda = sinSigma * sinAlpha1 / (cosU1 * cosSigma - sinU1 *
    // sinSigma * cosAlpha1);
    // double lambda = Math.atan(tanLambda);
    final lambda = atan2(sinSigma * sinAlpha1,
        (cosU1 * cosSigma - sinU1 * sinSigma * cosAlpha1));
    // eq. 10
    final C = (f / 16) * cos2Alpha * (4 + f * (4 - 3 * cos2Alpha));
    // eq. 11
    final L = lambda -
        (1 - C) *
            f *
            sinAlpha *
            (sigma +
                C *
                    sinSigma *
                    (cosSigmaM2 + C * cosSigma * (-1 + 2 * cos2SigmaM2)));
    // eq. 12
    // double alpha2 = Math.atan2(sinAlpha, -sinU1 * sinSigma + cosU1 *
    // cosSigma * cosAlpha1);
    // build result
    var latitude = toDegrees(phi2);
    var longitude = start.longitude + toDegrees(L);
    // if ((endBearing != null) && (endBearing.length > 0)) {
    // endBearing[0] = toDegrees(alpha2);
    // }
    latitude = latitude < -90 ? -90 : latitude;
    latitude = latitude > 90 ? 90 : latitude;
    longitude = longitude < -180 ? -180 : longitude;
    longitude = longitude > 180 ? 180 : longitude;
    return LatLng(latitude, longitude);
  }

  static Future<MapAddress> placemarkFromCoordinates(LatLng center) async {
    // String result = '(none)';
    final result = MapAddress();
    try {
      var placemarks = await Geolocator().placemarkFromCoordinates(
          center.latitude, center.longitude,
          localeIdentifier: 'ru');
      final placemark = placemarks[0];
      if (placemark.locality != '') {
        result.simple = placemark.locality;
      } else if (placemark.subAdministrativeArea != '') {
        result.simple = placemark.subAdministrativeArea;
      } else if (placemark.administrativeArea != '') {
        result.simple = placemark.administrativeArea;
      } else if (placemark.country != '') {
        result.simple = placemark.country;
      }
      if (placemark.thoroughfare != '') {
        result.detail = result.simple + ', ' + placemark.thoroughfare;
      } else if (placemark.name != '' && placemark.name != result.simple) {
        result.detail = result.simple + ', ' + placemark.name;
      }
    } catch (error) {
      debugPrint('$error');
    }
    return result;
  }
}

class MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
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
  final markerIconSize = 48.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  // TODO: добавить анимацию удаления-приближения zoom при выполнении перемещения карты
  void animatedMapMove({LatLng destCenter, double destZoom}) {
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
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if ([AnimationStatus.completed, AnimationStatus.dismissed]
          .contains(status)) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: widget.center,
        zoom: widget.zoom,
        minZoom: 4,
        onPositionChanged: widget.onPositionChanged,
        onLongPress: _handleLongPress,
        plugins: <MapPlugin>[
          widget.isMyUnit ? MapMyUnitLayer() : MapAreaLayer(),
          MapScaleLayer(),
          if (isInDebugMode) MapZoomLayer(),
        ],
      ),
      layers: <LayerOptions>[
        TileLayerOptions(
          urlTemplate: kTilesEndpoint,
          tileProvider: CachedNetworkTileProvider(),
        ),
        if (appState['currentPosition'] != null)
          CircleLayerOptions(circles: <CircleMarker>[
            CircleMarker(
              // useRadiusInMeter: true,
              radius: 4,
              color: Colors.blue,
              borderColor: Colors.black,
              borderStrokeWidth: 1,
              point: LatLng(
                appState['currentPosition'][0] as double,
                appState['currentPosition'][1] as double,
              ),
            ),
          ]),
        if (widget.markerPoint != null)
          MarkerLayerOptions(
            markers: <Marker>[
              Marker(
                width: markerIconSize,
                height: markerIconSize,
                point: widget.markerPoint,
                anchorPos: AnchorPos.align(AnchorAlign.top),
                builder: (_) => Icon(
                  Icons.location_on,
                  size: markerIconSize,
                  color: Colors.pinkAccent,
                ),
              ),
            ],
          ),
        if (widget.isMyUnit)
          MapMyUnitLayerOptions(
            markerIconSize: markerIconSize,
            onCurrentPosition: _onCurrentPosition,
          ),
        if (!widget.isMyUnit)
          MapAreaLayerOptions(
            markerIconSize: markerIconSize,
            onCurrentPosition: _onCurrentPosition,
            saveModes: widget.saveModes,
            // onMoveToCurrentPosition: (destCenter, destZoom) {
            //   setState(() {
            //     _currentPosition = destCenter;
            //   });
            //   animatedMapMove(destCenter, destZoom);
            // },
          ),
        MapScaleLayerOption(
          lineColor: Colors.blue,
          lineWidth: 2,
          textStyle: TextStyle(color: Colors.blue, fontSize: kFontSize),
          padding: EdgeInsets.all(10),
        ),
        if (isInDebugMode) MapZoomLayerOptions(),
      ],
    );
  }

  void _onCurrentPosition(Position position) {
    setState(() {
      appState['currentPosition'] = [position.latitude, position.longitude];
      // _currentPosition =
      //     LatLng(position.latitude, position.longitude);
      animatedMapMove(
        destCenter: LatLng(position.latitude, position.longitude),
        destZoom: 10,
      );
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
  }

  void _handleLongPress(LatLng point) async {
    final url = Platform.isIOS
        ? 'http://maps.apple.com/?ll=${point.latitude},${point.longitude}'
        : 'geo:${point.latitude},${point.longitude}';
    if (!await canLaunch(url)) {
      throw 'Could not launch $url';
    }
    await launch(url);
  }
}
