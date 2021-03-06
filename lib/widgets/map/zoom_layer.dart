import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';

class MapZoomLayerOptions extends LayerOptions {
  final bool debugEnableOnly;
  MapZoomLayerOptions({this.debugEnableOnly = true});
}

class MapZoomLayer implements MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<void> stream) {
    // if (!(options is MapZoomLayerOptions)) {
    //   throw 'Unknown options type for MapZoomLayer: $options';
    // }
    return _MapZoomLayer(options as MapZoomLayerOptions, mapState);
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is MapZoomLayerOptions;
  }
}

class _MapZoomLayer extends StatefulWidget {
  final MapState mapState;

  _MapZoomLayer(MapZoomLayerOptions options, this.mapState)
      : super(key: options.key);

  @override
  _MapZoomLayerState createState() => _MapZoomLayerState();
}

class _MapZoomLayerState extends State<_MapZoomLayer> {
  @override
  Widget build(BuildContext context) {
    return ButtonBar(
      children: <Widget>[
        IconButton(
          tooltip: 'Increase',
          iconSize: 32,
          icon: Icon(
            Icons.zoom_in,
          ),
          onPressed:
              widget.mapState.zoom < (widget.mapState.options.maxZoom ?? 17)
                  ? _increaseZoom
                  : null,
        ),
        IconButton(
          tooltip: 'Decrease',
          iconSize: 32,
          icon: Icon(
            Icons.zoom_out,
          ),
          onPressed:
              widget.mapState.zoom > (widget.mapState.options.minZoom ?? 0)
                  ? _decreaseZoom
                  : null,
        ),
      ],
    );
  }

  void _increaseZoom() {
    final zoom = widget.mapState.zoom + 1;
    widget.mapState.move(widget.mapState.center, zoom);
  }

  void _decreaseZoom() {
    final zoom = widget.mapState.zoom - 1;
    widget.mapState.move(widget.mapState.center, zoom);
  }
}
