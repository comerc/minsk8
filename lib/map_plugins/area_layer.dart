import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'utils.dart' as utils;

// typedef void OnMoveToCurrentPosition(LatLng destCenter, double destZoom);

typedef void OnChangeRadiusCallback(double value);

class AreaLayerMapPluginOptions extends LayerOptions {
  final double markerIconSize;
  final double initialRadius;
  final OnChangeRadiusCallback onChangeRadius;
  final Function onCurrentPositionClick;
  // final OnMoveToCurrentPosition onMoveToCurrentPosition;

  AreaLayerMapPluginOptions({
    this.markerIconSize,
    this.initialRadius,
    this.onChangeRadius,
    this.onCurrentPositionClick,
  });
}

class AreaLayerMapPlugin implements MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<Null> stream) {
    if (!(options is AreaLayerMapPluginOptions)) {
      throw Exception('Unknown options type for AreaLayerMapPlugin'
          'plugin: $options');
    }
    return _Area(options: options, mapState: mapState);
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is AreaLayerMapPluginOptions;
  }
}

class _Area extends StatefulWidget {
  final AreaLayerMapPluginOptions options;
  final MapState mapState;

  _Area({Key key, this.options, this.mapState}) : super(key: key);

  @override
  _AreaState createState() => _AreaState();
}

const maxRadius = 100.0;

class _AreaState extends State<_Area> {
  final _icon = Icons.location_on;
  final _iconSmallSize = 16.0;
  final _boxShadow = BoxShadow(
    offset: Offset(0.0, 2.0),
    blurRadius: 2.0,
  );
  double radius;

  @override
  void initState() {
    super.initState();
    radius = widget.options.initialRadius ?? maxRadius / 2;
  }

  double get paintedRadius {
    final center = widget.mapState.center;
    final targetPoint =
        utils.calculateEndingGlobalCoordinates(center, 90, radius * 1000.0);
    final start = widget.mapState.project(center);
    final end = widget.mapState.project(targetPoint);
    return end.x - start.x;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.options.onChangeRadius != null)
          Center(
            child: CustomPaint(
              painter: _AreaPainter(
                radius: paintedRadius,
                icon: _icon,
                iconSize: widget.options.markerIconSize,
              ),
            ),
          ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(
                right: 16.0,
                bottom: 16.0,
              ),
              child: Container(
                height: 56.0,
                width: 56.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(28.0)),
                  boxShadow: [_boxShadow],
                ),
                child: FlatButton(
                  child: Icon(
                    Icons.my_location,
                  ),
                  shape: CircleBorder(),
                  onPressed: widget.options.onCurrentPositionClick,
                ),
              ),
            ),
            if (widget.options.onChangeRadius != null)
              Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  height: 100.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    boxShadow: [_boxShadow],
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
                                          text: String.fromCharCode(
                                              _icon.codePoint),
                                          style: TextStyle(
                                            fontSize: _iconSmallSize,
                                            fontFamily: _icon.fontFamily,
                                            color: Colors.pinkAccent,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    style: DefaultTextStyle.of(context)
                                        .style
                                        .copyWith(fontWeight: FontWeight.w600),
                                    text: '${radius.toInt()} км',
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
                            value: radius,
                            onChanged: (value) {
                              setState(() {
                                radius = value;
                                widget.options.onChangeRadius(value);
                              });
                            },
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
        ),
      ],
    );
  }
}

class _AreaPainter extends CustomPainter {
  final double iconSize;
  final double radius;
  final Paint _paintFill;
  final Paint _paintStroke;
  final TextPainter _textPainter;

  _AreaPainter({this.radius, IconData icon, this.iconSize})
      : _paintFill = Paint()
          ..color = Colors.blue.withOpacity(0.1)
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
                  fontSize: iconSize,
                  fontFamily: icon.fontFamily,
                  color: Colors.pinkAccent))
          ..layout();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(0.0, 0.0), radius, _paintFill);
    canvas.drawCircle(Offset(0.0, 0.0), radius, _paintStroke);
    _textPainter.paint(
        canvas, Offset(-iconSize / 2, -iconSize)); // TODO: +4 ???
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
