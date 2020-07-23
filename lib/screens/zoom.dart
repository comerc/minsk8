import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:minsk8/import.dart';

// TODO: внедрить свайпы для переходов между картинками,
// для этого нужна карусель на одном общем Screen - PageView

class ZoomScreen extends StatefulWidget {
  ZoomScreen(this.arguments);

  final ZoomRouteArguments arguments;

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
  List<double> doubleTapScales = [1, 1.5, 2];
  int _currentIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
    _currentIndex = widget.arguments.index;
    final unit = widget.arguments.unit;
    App.analytics
        .setCurrentScreen(screenName: '/zoom ${unit.id} [$_currentIndex]');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.arguments.unit;
    final tag = widget.arguments.tag;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Material(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: tag,
              child: ExtendedImage.network(
                unit.images[_currentIndex].getLargeDummyUrl(unit.id),
                fit: BoxFit.contain,
                loadStateChanged: loadStateChanged,
                //enableLoadState: false,
                mode: ExtendedImageMode.gesture,
                initGestureConfigHandler: (state) {
                  var initialScale = 1.0;
                  if (state.extendedImageInfo != null &&
                      state.extendedImageInfo.image != null) {
                    // TODO: пока работает неправильно при смене ориентации
                    // final size = MediaQuery.of(context).size;
                    // initialScale = _initScale(
                    //     size: size,
                    //     initialScale: initialScale,
                    //     imageSize: Size(
                    //         state.extendedImageInfo.image.width.toDouble(),
                    //         state.extendedImageInfo.image.height.toDouble()));
                  }
                  return GestureConfig(
                    minScale: 0.9,
                    animationMinScale: 0.7,
                    maxScale: 4,
                    animationMaxScale: 4.5,
                    speed: 1,
                    inertialSpeed: 100,
                    initialScale: initialScale,
                    inPageView: false,
                    initialAlignment: InitialAlignment.center,
                  );
                },
                onDoubleTap: (ExtendedImageGestureState state) {
                  ///you can use define pointerDownPosition as you can,
                  ///default value is double tap pointer down position.
                  final pointerDownPosition = state.pointerDownPosition;
                  var begin = state.gestureDetails.totalScale;
                  double end;
                  //remove old
                  _animation?.removeListener(animationListener);
                  //stop pre
                  _animationController.stop();
                  //reset to use
                  _animationController.reset();
                  if (begin == doubleTapScales[0]) {
                    end = doubleTapScales[1];
                  } else if (begin == doubleTapScales[1]) {
                    end = doubleTapScales[2];
                  } else {
                    end = doubleTapScales[0];
                  }
                  animationListener = () {
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
            ),
            Positioned(
              top: 28,
              left: 0,
              right: 16,
              child: Row(
                children: [
                  Tooltip(
                    message: 'Close',
                    child: ButtonTheme(
                      minWidth: 0,
                      padding: EdgeInsets.all(12),
                      child: FlatButton(
                        onPressed: () {
                          Navigator.maybePop(context);
                        },
                        shape: CircleBorder(),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  if (unit.images.length > 1)
                    Text(
                      '${_currentIndex + 1}/${unit.images.length}',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            if (unit.images.length > 1)
              Center(
                child: Row(
                  children: [
                    Tooltip(
                      message: 'Back',
                      child: ButtonTheme(
                        minWidth: 0,
                        padding: EdgeInsets.all(12),
                        child: FlatButton(
                          onPressed: () {
                            _jumpToPage(isNext: false);
                          },
                          shape: CircleBorder(),
                          child: Icon(
                            Icons.navigate_before,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Tooltip(
                      message: 'Next',
                      child: ButtonTheme(
                        minWidth: 0,
                        padding: EdgeInsets.all(12),
                        child: FlatButton(
                          onPressed: () {
                            _jumpToPage(isNext: true);
                          },
                          shape: CircleBorder(),
                          child: Icon(
                            Icons.navigate_next,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return widget.arguments.onWillPop(_currentIndex);
  }

  // double _initScale({Size imageSize, Size size, double initialScale}) {
  //   var n1 = imageSize.height / imageSize.width;
  //   var n2 = size.height / size.width;
  //   if (n1 > n2) {
  //     final FittedSizes fittedSizes =
  //         applyBoxFit(BoxFit.contain, imageSize, size);
  //     //final Size sourceSize = fittedSizes.source;
  //     Size destinationSize = fittedSizes.destination;
  //     return size.width / destinationSize.width;
  //   } else if (n1 / n2 < 1 / 4) {
  //     final FittedSizes fittedSizes =
  //         applyBoxFit(BoxFit.contain, imageSize, size);
  //     //final Size sourceSize = fittedSizes.source;
  //     Size destinationSize = fittedSizes.destination;
  //     return size.height / destinationSize.height;
  //   }
  //   return initialScale;
  // }

  void _jumpToPage({bool isNext}) {
    final unit = widget.arguments.unit;
    final tag = widget.arguments.tag;
    final onWillPop = widget.arguments.onWillPop;
    final lastIndex = unit.images.length - 1;
    // Navigator.pushAndRemoveUntil(
    Navigator.pushReplacement(
      context,
      buildInitialRoute('/zoom')(
        (BuildContext context) => ZoomScreen(
          ZoomRouteArguments(
            unit,
            tag: tag,
            index: isNext
                ? _currentIndex == lastIndex ? 0 : _currentIndex + 1
                : _currentIndex == 0 ? lastIndex : _currentIndex - 1,
            onWillPop: onWillPop,
          ),
        ),
      ),
    );
  }
}

typedef WillPopZoomCallback = Future<bool> Function(int index);

class ZoomRouteArguments {
  ZoomRouteArguments(this.unit, {this.tag, this.index, this.onWillPop});

  final UnitModel unit;
  final String tag;
  final int index;
  final WillPopZoomCallback onWillPop;
}
