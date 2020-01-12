import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:minsk8/import.dart';

class ItemZoomScreen extends StatefulWidget {
  @override
  _ItemZoomScreenState createState() {
    return _ItemZoomScreenState();
  }
}

class _ItemZoomScreenState extends State<ItemZoomScreen>
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
        ModalRoute.of(context).settings.arguments as ItemZoomRouteArguments;
    final item = arguments.item;
    final index = arguments.index;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Material(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  Size size = Size(constraints.maxWidth, constraints.maxHeight);
                  print('$size');
                  return ExtendedImage.network(
                    item.images[index].getDummyUrl(item.id),
                    fit: BoxFit.contain,
                    loadStateChanged: (state) {
                      if (state.extendedImageLoadState != LoadState.loading)
                        return null;
                      return Container(
                        alignment: Alignment.center,
                        color: Colors.grey.withOpacity(0.3),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation(
                              Theme.of(context).primaryColor),
                        ),
                      );
                    },
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
                  );
                },
              ),
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
    return true;
  }
}

class ItemZoomRouteArguments {
  final ItemModel item;
  final String tag;
  final int index;

  ItemZoomRouteArguments(this.item, {this.tag, this.index});
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
