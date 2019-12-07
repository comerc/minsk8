import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';

class ZoomLayerPluginOptions extends LayerOptions {
  final bool debugEnableOnly;
  ZoomLayerPluginOptions({this.debugEnableOnly = true});
}

class ZoomLayerPlugin implements MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<Null> stream) {
    if (options is ZoomLayerPluginOptions) {
      return _Zoom(mapState: mapState);
    }
    throw Exception('Unknown options type for ZoomLayerPlugin'
        'plugin: $options');
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is ZoomLayerPluginOptions;
  }
}

class _Zoom extends StatefulWidget {
  final MapState mapState;

  _Zoom({Key key, this.mapState}) : super(key: key);

  @override
  _ZoomState createState() => _ZoomState();
}

class _ZoomState extends State<_Zoom> {
  @override
  Widget build(BuildContext context) {
    return ButtonBar(
      children: [
        IconButton(
          tooltip: 'Increase',
          iconSize: 32.0,
          icon: Icon(
            Icons.zoom_in,
          ),
          onPressed:
              widget.mapState.zoom < (widget.mapState.options.maxZoom ?? 17.0)
                  ? _increaseZoom
                  : null,
        ),
        IconButton(
          tooltip: 'Decrease',
          iconSize: 32.0,
          icon: Icon(
            Icons.zoom_out,
          ),
          onPressed:
              widget.mapState.zoom > (widget.mapState.options.minZoom ?? 0.0)
                  ? _decreaseZoom
                  : null,
        ),
      ],
    );
  }

  _increaseZoom() {
    final zoom = widget.mapState.zoom + 1;
    widget.mapState.move(widget.mapState.center, zoom);
  }

  _decreaseZoom() {
    final zoom = widget.mapState.zoom - 1;
    widget.mapState.move(widget.mapState.center, zoom);
  }
}
