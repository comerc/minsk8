import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import './utils.dart' as utils;

class AreaLayerPluginOptions extends LayerOptions {}

class AreaLayerPlugin implements MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<Null> stream) {
    if (options is AreaLayerPluginOptions) {
      return _Area(mapState: mapState);
    }
    throw Exception('Unknown options type for AreaLayerPlugin'
        'plugin: $options');
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is AreaLayerPluginOptions;
  }
}

class _Area extends StatefulWidget {
  final MapState mapState;

  _Area({Key key, this.mapState}) : super(key: key);

  @override
  _AreaState createState() => _AreaState();
}

const maxRadius = 100.0;

class _AreaState extends State<_Area> {
  double _radius = maxRadius / 2;
  final _icon = Icons.location_on;
  final _iconSmallSize = 16.0;

  @override
  Widget build(BuildContext context) {
    final center = widget.mapState.center;
    final start = widget.mapState.project(center);
    final targetPoint =
        utils.calculateEndingGlobalCoordinates(center, 90, _radius * 1000.0);
    final end = widget.mapState.project(targetPoint);
    final paintedRadius = end.x - start.x;
    // print(radius);
    return Stack(
      children: [
        Center(
          child: CustomPaint(
            painter: _AreaPainter(radius: paintedRadius, icon: _icon),
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.center,
            height: 100.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              // border: Border.all(color: Colors.black.withOpacity(0.2)),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 8.0),
                  blurRadius: 8.0,
                  // spreadRadius: 4.0,
                )
              ],
            ),
            child: Column(
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                    height: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                              text: 'Радиус',
                            ),
                            WidgetSpan(
                              child: SizedBox(
                                height: _iconSmallSize,
                                child: RichText(
                                  text: TextSpan(
                                    text: String.fromCharCode(_icon.codePoint),
                                    style: TextStyle(
                                      fontSize: _iconSmallSize,
                                      fontFamily: _icon.fontFamily,
                                      color: Colors.pink,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            TextSpan(
                              style: DefaultTextStyle.of(context)
                                  .style
                                  .copyWith(fontWeight: FontWeight.w600),
                              text: '${_radius.toInt()} км',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    child: Slider(
                      value: _radius,
                      onChanged: (value) =>
                          setState(() => _radius = value.roundToDouble()),
                      min: 1.0,
                      max: maxRadius,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AreaPainter extends CustomPainter {
  final _radius;
  final Paint _paintFill;
  final Paint _paintStroke;
  final TextPainter _textPainter;

  _AreaPainter({double radius, IconData icon})
      : _radius = radius,
        _paintFill = Paint()
          ..color = Colors.blue.withOpacity(0.2)
          ..strokeWidth = 0.0
          ..style = PaintingStyle.fill,
        _paintStroke = Paint()
          ..color = Colors.black.withOpacity(0.1)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke,
        _textPainter = TextPainter(textDirection: TextDirection.rtl)
          ..text = TextSpan(
              text: String.fromCharCode(icon.codePoint),
              style: TextStyle(
                  fontSize: 48.0,
                  fontFamily: icon.fontFamily,
                  color: Colors.pink))
          ..layout();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(0.0, 0.0), _radius, _paintFill);
    canvas.drawCircle(Offset(0.0, 0.0), _radius, _paintStroke);
    _textPainter.paint(canvas, Offset(-24.0, -44.0));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
