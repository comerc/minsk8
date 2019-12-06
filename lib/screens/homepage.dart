import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';

// import '../widgets/drawer.dart';

class Homepage extends StatelessWidget {
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
            AreaPlugin(),
          ],
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: 'https://tilessputnik.ru/{z}/{x}/{y}.png',
            tileProvider: CachedNetworkTileProvider(),
          ),
          MarkerLayerOptions(markers: markers),
          AreaPluginOptions(text: "I'm a plugin!"),
        ],
      ),
    );
  }
}

class AreaPluginOptions extends LayerOptions {
  final String text;
  AreaPluginOptions({this.text = ''});
}

class AreaPlugin implements MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<Null> stream) {
    if (options is AreaPluginOptions) {
      return _Area(mapState);
    }
    throw Exception('Unknown options type for Area'
        'plugin: $options');
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is AreaPluginOptions;
  }
}

class _Area extends StatelessWidget {
  final MapState mapState;

  _Area(this.mapState);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: CustomPaint(
            painter: _AreaPainter(),
          ),
        ),
        kReleaseMode
            ? null
            : ButtonBar(
                children: [
                  IconButton(
                    tooltip: 'Увеличить',
                    iconSize: 32.0,
                    icon: Icon(
                      Icons.zoom_in,
                    ),
                    onPressed:
                        mapState.zoom < (mapState.options.maxZoom ?? 17.0)
                            ? _increaseZoom
                            : null,
                  ),
                  IconButton(
                    tooltip: 'Уменьшить',
                    iconSize: 32.0,
                    icon: Icon(
                      Icons.zoom_out,
                    ),
                    onPressed: mapState.zoom > (mapState.options.minZoom ?? 0.0)
                        ? _decreaseZoom
                        : null,
                  ),
                ],
              ),
      ].where((child) => child != null).toList(),
    );
  }

  _increaseZoom() {
    final zoom = mapState.zoom + 1;
    mapState.move(mapState.center, zoom);
  }

  _decreaseZoom() {
    final zoom = mapState.zoom - 1;
    mapState.move(mapState.center, zoom);
  }
}

class _AreaPainter extends CustomPainter {
  Paint _paintFill;
  Paint _paintStroke;
  TextPainter _textPainter;

  _AreaPainter() {
    _paintFill = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..strokeWidth = 0.0
      ..style = PaintingStyle.fill;
    _paintStroke = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final icon = Icons.location_on;
    _textPainter = TextPainter(textDirection: TextDirection.rtl);
    _textPainter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
            fontSize: 48.0, fontFamily: icon.fontFamily, color: Colors.pink));
    _textPainter.layout();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(0.0, 0.0), 100.0, _paintFill);
    canvas.drawCircle(Offset(0.0, 0.0), 100.0, _paintStroke);
    _textPainter.paint(canvas, Offset(-24.0, -44.0));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
