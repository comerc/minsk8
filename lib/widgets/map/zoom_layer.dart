import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';

class MapZoomLayerOptions extends LayerOptions {
  final bool debugEnableOnly;
  MapZoomLayerOptions({this.debugEnableOnly = true});
}

class MapZoomLayer implements MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<Null> stream) {
    if (!(options is MapZoomLayerOptions)) {
      throw Exception('Unknown options type for MapZoomLayer'
          'plugin: $options');
    }
    return _MapZoomLayer(mapState: mapState);
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is MapZoomLayerOptions;
  }
}

class _MapZoomLayer extends StatefulWidget {
  final MapState mapState;

  _MapZoomLayer({Key key, this.mapState}) : super(key: key);

  @override
  _MapZoomLayerState createState() => _MapZoomLayerState();
}

class _MapZoomLayerState extends State<_MapZoomLayer> {
  @override
  Widget build(BuildContext context) {
    return ButtonBar(
      children: [
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

  _increaseZoom() {
    final zoom = widget.mapState.zoom + 1;
    widget.mapState.move(widget.mapState.center, zoom);
  }

  _decreaseZoom() {
    final zoom = widget.mapState.zoom - 1;
    widget.mapState.move(widget.mapState.center, zoom);
  }
}
