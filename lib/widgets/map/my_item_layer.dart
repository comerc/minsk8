import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

class MapMyItemLayerOptions extends LayerOptions {
  final double markerIconSize;
  final MapCurrentPositionCallback onCurrentPosition;

  MapMyItemLayerOptions({
    this.markerIconSize,
    this.onCurrentPosition,
  });
}

class MapMyItemLayer implements MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<Null> stream) {
    if (!(options is MapMyItemLayerOptions)) {
      throw Exception('Unknown options type for MapMyItemLayer'
          'plugin: $options');
    }
    return _MapMyItemLayer(options: options, mapState: mapState);
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is MapMyItemLayerOptions;
  }
}

class _MapMyItemLayer extends StatefulWidget {
  final MapMyItemLayerOptions options;
  final MapState mapState;

  _MapMyItemLayer({Key key, this.options, this.mapState}) : super(key: key);

  @override
  _MapMyItemLayerState createState() => _MapMyItemLayerState();
}

class _MapMyItemLayerState extends State<_MapMyItemLayer> {
  @override
  void initState() {
    super.initState();
    final myItemMap = Provider.of<MyItemMapModel>(context, listen: false);
    myItemMap.init();
  }

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
          margin: EdgeInsets.only(top: 60),
          alignment: Alignment.center,
          child: _Label(),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            MapCurrentPosition(
              onCurrentPosition: widget.options.onCurrentPosition,
            ),
            MapReadyButton(
              center: widget.mapState.center,
              zoom: widget.mapState.zoom,
              saveModes: [MapSaveMode.myItem],
            ),
          ],
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final myItemMap = Provider.of<MyItemMapModel>(context);
    return _AnimatedLabel(
      visible: myItemMap.visible,
      address: myItemMap.address,
    );
  }
}

class _AnimatedLabel extends StatefulWidget {
  final bool visible;
  final String address;

  _AnimatedLabel({this.visible, this.address});

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
    _animation = Tween<double>(begin: 1, end: 0).animate(_controller)
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
      // print('forward');
      _controller.forward();
    }
    if (!oldWidget.visible && widget.visible) {
      // print('reverse');
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _animation.value,
      child: Container(
        padding: EdgeInsets.all(8),
        color: Colors.white.withOpacity(0.8),
        child: Text(
          widget.address,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
