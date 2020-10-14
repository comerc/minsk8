import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:minsk8/import.dart';

class MapScaleLayerOption extends LayerOptions {
  TextStyle textStyle;
  Color lineColor;
  double lineWidth;
  final EdgeInsets padding;

  MapScaleLayerOption(
      {this.textStyle,
      this.lineColor = Colors.white,
      this.lineWidth = 2,
      this.padding});
}

class MapScaleLayer implements MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<void> stream) {
    // if (!(options is MapScaleLayerOption)) {
    //   throw 'Unknown options type for MapScaleLayer: $options';
    // }
    return _MapScaleLayer(options as MapScaleLayerOption, mapState, stream);
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is MapScaleLayerOption;
  }
}

class _MapScaleLayer extends StatelessWidget {
  final MapScaleLayerOption options;
  final MapState mapState;
  final Stream<void> stream;
  final scale = [
    25000000,
    15000000,
    8000000,
    4000000,
    2000000,
    1000000,
    500000,
    250000,
    100000,
    50000,
    25000,
    15000,
    8000,
    4000,
    2000,
    1000,
    500,
    250,
    100,
    50,
    25,
    10,
    5
  ];

  _MapScaleLayer(this.options, this.mapState, this.stream)
      : super(key: options.key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (BuildContext context, _) {
        final zoom = mapState.zoom;
        final distance = scale[max(0, min(20, zoom.round() + 2))].toDouble();
        final center = mapState.center;
        final start = mapState.project(center);
        final targetPoint =
            MapWidget.calculateEndingGlobalCoordinates(center, 90, distance);
        final end = mapState.project(targetPoint);
        final displayDistance = distance > 999
            ? '${(distance / 1000).toStringAsFixed(0)} km'
            : '${distance.toStringAsFixed(0)} m';
        final width = end.x - start.x;
        return CustomPaint(
          painter: _MapScalePainter(
            width as double,
            displayDistance,
            lineColor: options.lineColor,
            lineWidth: options.lineWidth,
            padding: options.padding,
            textStyle: options.textStyle,
          ),
        );
      },
    );
  }
}

class _MapScalePainter extends CustomPainter {
  _MapScalePainter(this.width, this.text,
      {this.padding, this.textStyle, this.lineWidth, this.lineColor});
  final double width;
  final EdgeInsets padding;
  final String text;
  TextStyle textStyle;
  double lineWidth;
  Color lineColor;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.square
      ..strokeWidth = lineWidth;

    final sizeForStartEnd = 4;
    final paddingLeft =
        padding == null ? 0.0 : padding.left + sizeForStartEnd / 2;
    var paddingTop = padding == null ? 0.0 : padding.top;
    final textSpan = TextSpan(style: textStyle, text: text);
    final textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    textPainter.paint(canvas,
        Offset(width / 2 - textPainter.width / 2 + paddingLeft, paddingTop));
    paddingTop += textPainter.height;
    final p1 = Offset(paddingLeft, sizeForStartEnd + paddingTop);
    final p2 = Offset(paddingLeft + width, sizeForStartEnd + paddingTop);
    // draw start line
    canvas.drawLine(Offset(paddingLeft, paddingTop),
        Offset(paddingLeft, sizeForStartEnd + paddingTop), paint);
    // draw middle line
    final middleX = width / 2 + paddingLeft - lineWidth / 2;
    canvas.drawLine(Offset(middleX, paddingTop + sizeForStartEnd / 2),
        Offset(middleX, sizeForStartEnd + paddingTop), paint);
    // draw end line
    canvas.drawLine(Offset(width + paddingLeft, paddingTop),
        Offset(width + paddingLeft, sizeForStartEnd + paddingTop), paint);
    // draw bottom line
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
