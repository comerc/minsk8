import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';

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

class _AreaState extends State<_Area> {
  double _value = 200.0;
  final _icon = Icons.location_on;
  final _iconSmallSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: CustomPaint(
            painter: _AreaPainter(value: _value, icon: _icon),
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
                              text: '${_value.toInt()} км',
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
                      value: _value,
                      onChanged: (value) =>
                          setState(() => _value = value.roundToDouble()),
                      min: 3.0,
                      max: 200.0,
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
  final _value;
  final Paint _paintFill;
  final Paint _paintStroke;
  final TextPainter _textPainter;

  _AreaPainter({double value, IconData icon})
      : _value = value,
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
    canvas.drawCircle(Offset(0.0, 0.0), _value, _paintFill);
    canvas.drawCircle(Offset(0.0, 0.0), _value, _paintStroke);
    _textPainter.paint(canvas, Offset(-24.0, -44.0));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
