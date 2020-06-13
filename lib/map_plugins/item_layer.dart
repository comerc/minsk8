import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

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

class _ItemLayerState extends State<_ItemLayer> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: widget.options.markerIconSize),
          alignment: Alignment.center,
          child: Icon(
            Icons.location_on,
            size: widget.options.markerIconSize,
            color: Colors.pinkAccent,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 60.0),
          alignment: Alignment.center,
          child: _Label(),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: widget.options.footer,
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final itemMap = Provider.of<ItemMapModel>(context);
    return _AnimatedLabel(visible: itemMap.visible, value: itemMap.value);
  }
}

class _AnimatedLabel extends StatefulWidget {
  final bool visible;
  final String value;

  _AnimatedLabel({this.visible, this.value});

  @override
  _AnimatedLabelState createState() => _AnimatedLabelState();
}

class _AnimatedLabelState extends State<_AnimatedLabel>
    with SingleTickerProviderStateMixin {
  Animation<double> _animation;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: kAnimationTime), vsync: this);
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_AnimatedLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible && !widget.visible) {
      print('forward');
      _controller.forward();
    }
    if (!oldWidget.visible && widget.visible) {
      print('reverse');
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _animation.value,
      child: Container(
        padding: EdgeInsets.all(8.0),
        color: Colors.green,
        child: Text(
          widget.value,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
