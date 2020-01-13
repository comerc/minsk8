import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:minsk8/import.dart';

class ZoomScreen extends StatefulWidget {
  @override
  _ZoomScreenState createState() {
    return _ZoomScreenState();
  }
}

class _ZoomScreenState extends State<ZoomScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;
  Function animationListener;
  List<double> doubleTapScales = <double>[1.0, 2.0];

  var _isCarouselSlider = true;
  var _isHero = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context).settings.arguments as ZoomRouteArguments;
    final item = arguments.item;
    final tag = arguments.tag;
    final index = arguments.index;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Material(
        child: Stack(
          fit: StackFit.expand,
          children: [
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                Size size = Size(constraints.maxWidth, constraints.maxHeight);
                return Hero(
                  tag: tag,
                  child: ExtendedImage.network(
                    item.images[index].getLargeDummyUrl(item.id),
                    fit: BoxFit.contain,
                    loadStateChanged: loadStateChanged,
                    //enableLoadState: false,
                    mode: ExtendedImageMode.gesture,
                    initGestureConfigHandler: (state) {
                      double initialScale = 1.0;
                      if (state.extendedImageInfo != null &&
                          state.extendedImageInfo.image != null) {
                        initialScale = initScale(
                            size: size,
                            initialScale: initialScale,
                            imageSize: Size(
                                state.extendedImageInfo.image.width.toDouble(),
                                state.extendedImageInfo.image.height
                                    .toDouble()));
                      }
                      return GestureConfig(
                        minScale: 0.9,
                        animationMinScale: 0.7,
                        maxScale: 4.0,
                        animationMaxScale: 4.5,
                        speed: 1.0,
                        inertialSpeed: 100.0,
                        initialScale: initialScale,
                        inPageView: false,
                        initialAlignment: InitialAlignment.center,
                      );
                    },
                    onDoubleTap: (ExtendedImageGestureState state) {
                      ///you can use define pointerDownPosition as you can,
                      ///default value is double tap pointer down postion.
                      var pointerDownPosition = state.pointerDownPosition;
                      double begin = state.gestureDetails.totalScale;
                      double end;
                      //remove old
                      _animation?.removeListener(animationListener);
                      //stop pre
                      _animationController.stop();
                      //reset to use
                      _animationController.reset();
                      if (begin == doubleTapScales[0]) {
                        end = doubleTapScales[1];
                      } else {
                        end = doubleTapScales[0];
                      }
                      animationListener = () {
                        //print(_animation.value);
                        state.handleDoubleTap(
                            scale: _animation.value,
                            doubleTapPosition: pointerDownPosition);
                      };
                      _animation = _animationController
                          .drive(Tween<double>(begin: begin, end: end));
                      _animation.addListener(animationListener);
                      _animationController.forward();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    setState(() {
      _isHero = true;
      _isCarouselSlider = false;
    });
    final arguments =
        ModalRoute.of(context).settings.arguments as ZoomRouteArguments;
    final index = arguments.index;
    arguments.onClose(index);
    return true;
  }
}

class ZoomRouteArguments {
  final ItemModel item;
  final String tag;
  final int index;
  final Function onClose;

  ZoomRouteArguments(this.item, {this.tag, this.index, this.onClose});
}

double initScale({Size imageSize, Size size, double initialScale}) {
  var n1 = imageSize.height / imageSize.width;
  var n2 = size.height / size.width;
  if (n1 > n2) {
    final FittedSizes fittedSizes =
        applyBoxFit(BoxFit.contain, imageSize, size);
    //final Size sourceSize = fittedSizes.source;
    Size destinationSize = fittedSizes.destination;
    return size.width / destinationSize.width;
  } else if (n1 / n2 < 1 / 4) {
    final FittedSizes fittedSizes =
        applyBoxFit(BoxFit.contain, imageSize, size);
    //final Size sourceSize = fittedSizes.source;
    Size destinationSize = fittedSizes.destination;
    return size.height / destinationSize.height;
  }

  return initialScale;
}
