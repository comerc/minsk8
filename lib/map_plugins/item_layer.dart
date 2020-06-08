import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';

class ItemLayerMapPluginOptions extends LayerOptions {
  final double markerIconSize;
  final List<Widget> footer;

  ItemLayerMapPluginOptions({
    this.markerIconSize,
    this.footer,
  });
}

class ItemLayerMapPlugin implements MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<Null> stream) {
    if (!(options is ItemLayerMapPluginOptions)) {
      throw Exception('Unknown options type for ItemLayerMapPlugin'
          'plugin: $options');
    }
    return _ItemLayer(options: options, mapState: mapState);
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is ItemLayerMapPluginOptions;
  }
}

class _ItemLayer extends StatefulWidget {
  final ItemLayerMapPluginOptions options;
  final MapState mapState;

  _ItemLayer({Key key, this.options, this.mapState}) : super(key: key);

  @override
  _ItemLayerState createState() => _ItemLayerState();
}

const maxRadius = 100.0;

class _ItemLayerState extends State<_ItemLayer>
    with SingleTickerProviderStateMixin {
  final _icon = Icons.location_on;
  Animation<double> _animation;
  AnimationController _controller;
  bool _visible;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _visible = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: widget.options.markerIconSize),
          alignment: Alignment.center,
          child: Icon(
            _icon,
            size: widget.options.markerIconSize,
            color: Colors.pinkAccent,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 60.0),
          alignment: Alignment.center,
          child: AnimatedLabel(animation: _animation),
        ),
        Center(
          child: Container(
            margin: EdgeInsets.only(top: 200.0),
            child: RaisedButton(
              onPressed: () {
                if (_visible) {
                  _controller.reverse();
                } else {
                  _controller.forward();
                }
                setState(() {
                  _visible = !_visible;
                });
              },
              child: Text(_visible ? 'On' : 'Off'),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: widget.options.footer,
        ),
      ],
    );
  }
}

class AnimatedLabel extends AnimatedWidget {
  AnimatedLabel({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Opacity(
      opacity: animation.value,
      child: Container(
        padding: EdgeInsets.all(8.0),
        color: Colors.green,
        child: Text(
          '1111',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
