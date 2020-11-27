import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:minsk8/import.dart';

// TODO: внедрить свайпы для переходов между картинками,
// для этого нужна карусель на одном общем Screen - PageView
// TODO: Исследовать ExtendedImage.heroBuilderForSlidingPage
// TODO: InteractiveViewer

// TODO: неправильно работает Hero, хорошо видно на увеличенном timeDilation

typedef ZoomWillPopCallback = Future<bool> Function(int index);

class ZoomScreen extends StatefulWidget {
  Route<T> getRoute<T>({bool isInitialRoute}) {
    return buildRoute<T>(
      '/zoom?unit_id=${unit.id}&index=[$index]',
      builder: (_) => this,
      fullscreenDialog: true,
      isInitialRoute: isInitialRoute,
    );
  }

  ZoomScreen(this.unit, {this.tag, this.index, this.onWillPop});

  final UnitModel unit;
  final String tag;
  final int index;
  final ZoomWillPopCallback onWillPop;

  @override
  _ZoomScreenState createState() {
    return _ZoomScreenState();
  }
}

class _ZoomScreenState extends State<ZoomScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  void Function() _animationListener;
  List<double> doubleTapScales = [1, 1.5, 2];
  int _currentIndex;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: Duration(milliseconds: 150), vsync: this);
    _currentIndex = widget.index;
    // final unit = widget.unit;
    // analytics.setCurrentScreen(screenName: '/zoom ${unit.id} [$_currentIndex]');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.unit;
    final tag = widget.tag;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Material(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Hero(
              tag: tag,
              child: ExtendedImage.network(
                unit.images[_currentIndex].getLargeDummyUrl(unit.id),
                fit: BoxFit.contain,
                loadStateChanged: loadStateChanged,
                mode: ExtendedImageMode.gesture,
                initGestureConfigHandler: (state) {
                  final initialScale = 1.0;
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
                  );
                },
                onDoubleTap: (ExtendedImageGestureState state) {
                  ///you can use define pointerDownPosition as you can,
                  ///default value is double tap pointer down position.
                  final pointerDownPosition = state.pointerDownPosition;
                  final begin = state.gestureDetails.totalScale;
                  double end;
                  //remove old
                  _animation?.removeListener(_animationListener);
                  //stop pre
                  _controller.stop();
                  //reset to use
                  _controller.reset();
                  if (begin == doubleTapScales[0]) {
                    end = doubleTapScales[1];
                  } else if (begin == doubleTapScales[1]) {
                    end = doubleTapScales[2];
                  } else {
                    end = doubleTapScales[0];
                  }
                  _animationListener = () {
                    state.handleDoubleTap(
                        scale: _animation.value,
                        doubleTapPosition: pointerDownPosition);
                  };
                  _animation =
                      _controller.drive(Tween<double>(begin: begin, end: end));
                  _animation.addListener(_animationListener);
                  _controller.forward();
                },
              ),
            ),
            Positioned(
              top: 28,
              left: 0,
              right: 16,
              child: Row(
                children: <Widget>[
                  _buidButton(
                    message: 'Close',
                    icon: Icons.close,
                    onTap: () {
                      navigator.maybePop();
                    },
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
                  children: <Widget>[
                    _buidButton(
                      message: 'Back',
                      icon: Icons.navigate_before,
                      onTap: () {
                        _jumpToPage(isNext: false);
                      },
                    ),
                    Spacer(),
                    _buidButton(
                      message: 'Next',
                      icon: Icons.navigate_next,
                      onTap: () {
                        _jumpToPage(isNext: true);
                      },
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
    return widget.onWillPop(_currentIndex);
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
    final unit = widget.unit;
    final tag = widget.tag;
    final onWillPop = widget.onWillPop;
    final lastIndex = unit.images.length - 1;
    final index = isNext
        ? _currentIndex == lastIndex
            ? 0
            : _currentIndex + 1
        : _currentIndex == 0
            ? lastIndex
            : _currentIndex - 1;
    // navigator.pushAndRemoveUntil(
    navigator.pushReplacement(
      ZoomScreen(
        unit,
        tag: tag,
        index: index,
        onWillPop: onWillPop,
      ).getRoute(isInitialRoute: true),
    );
  }

  Widget _buidButton({String message, IconData icon, void Function() onTap}) {
    // TODO: увеличить лужу через Stack + alignment: const Alignment(1.0, 1.0), или FittedBox, или BoxConstraints
    return Tooltip(
      message: message,
      child: ButtonTheme(
        minWidth: 0,
        padding: EdgeInsets.all((kToolbarHeight - kBigIconSize) / 2),
        child: FlatButton(
          onPressed: onTap,
          shape: CircleBorder(),
          child: Icon(
            icon,
            color: Colors.white,
            size: kBigIconSize,
          ),
        ),
      ),
    );
  }
}
