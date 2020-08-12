import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

class MapMyUnitLayerOptions extends LayerOptions {
  final double markerIconSize;
  final MapCurrentPositionCallback onCurrentPosition;

  MapMyUnitLayerOptions({
    this.markerIconSize,
    this.onCurrentPosition,
  });
}

class MapMyUnitLayer implements MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<Null> stream) {
    if (!(options is MapMyUnitLayerOptions)) {
      throw 'Unknown options type for MapMyUnitLayer: $options';
    }
    return _MapMyUnitLayer(options, mapState);
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is MapMyUnitLayerOptions;
  }
}

class _MapMyUnitLayer extends StatefulWidget {
  final MapMyUnitLayerOptions options;
  final MapState mapState;

  _MapMyUnitLayer(this.options, this.mapState) : super(key: options.key);

  @override
  _MapMyUnitLayerState createState() => _MapMyUnitLayerState();
}

class _MapMyUnitLayerState extends State<_MapMyUnitLayer> {
  @override
  void initState() {
    super.initState();
    final myUnitMap = Provider.of<MyUnitMapModel>(context, listen: false);
    myUnitMap.init();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
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
          children: <Widget>[
            MapCurrentPosition(
              onCurrentPosition: widget.options.onCurrentPosition,
            ),
            MapReadyButton(
              center: widget.mapState.center,
              zoom: widget.mapState.zoom,
              saveModes: <MapSaveMode>[MapSaveMode.myUnit],
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
    final myUnitMap = Provider.of<MyUnitMapModel>(context);
    return _AnimatedLabel(
      visible: myUnitMap.visible,
      address: myUnitMap.address,
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
