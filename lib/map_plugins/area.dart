import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';

class AreaPluginOptions extends LayerOptions {}

class AreaPlugin implements MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<Null> stream) {
    if (options is AreaPluginOptions) {
      return _Area(mapState: mapState);
    }
    throw Exception('Unknown options type for AreaPlugin'
        'plugin: $options');
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is AreaPluginOptions;
  }
}

class _Area extends StatefulWidget {
  final MapState mapState;

  _Area({Key key, this.mapState}) : super(key: key);

  @override
  _AreaState createState() => _AreaState();
}

class _AreaState extends State<_Area> {
  double _value = 0.0;
  final _icon = Icons.location_on;
  final _iconSmallSize = 16.0;

  @override
  Widget build(BuildContext context) {
    print(_value);
    return Stack(
      children: [
        Center(
          child: CustomPaint(
            painter: _AreaPainter(),
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
            child: Slider(
              value: _value,
              onChanged: (value) => setState(() => _value = value),
            ),
          ),
        ),
      ],
    );
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
