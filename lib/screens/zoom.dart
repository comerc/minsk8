import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:extended_image/extended_image.dart';
import 'package:minsk8/import.dart';

// TODO: внедрить свайпы для переходов между картинками,
// для этого нужна карусель на одном общем Screen

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.arguments.item;
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
                item.images[_currentIndex].getLargeDummyUrl(item.id),
                fit: BoxFit.contain,
                loadStateChanged: loadStateChanged,
                //enableLoadState: false,
                mode: ExtendedImageMode.gesture,
                initGestureConfigHandler: (state) {
                  double initialScale = 1;
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
                  if (item.images.length > 1)
                    Text(
                      '${_currentIndex + 1}/${item.images.length}',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            if (item.images.length > 1)
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

  _buildInitialRoute(WidgetBuilder builder) {
    final settings = RouteSettings(
      name: '/zoom',
      // isInitialRoute: true, // deprecated
    );
    return Platform.isIOS
        // ? CupertinoPageRoute(
        ? NoAnimationCupertinoPageRoute(
            builder: builder,
            settings: settings,
          )
        // : MaterialPageRoute(
        : NoAnimationMaterialPageRoute(
            builder: builder,
            settings: settings,
          );
  }

  _jumpToPage({bool isNext}) {
    final item = widget.arguments.item;
    final tag = widget.arguments.tag;
    final onWillPop = widget.arguments.onWillPop;
    final lastIndex = item.images.length - 1;
    // Navigator.pushAndRemoveUntil(
    Navigator.pushReplacement(
      context,
      _buildInitialRoute(
        (BuildContext context) => ZoomScreen(
          ZoomRouteArguments(
            item,
            tag: tag,
            index: isNext
                ? _currentIndex == lastIndex ? 0 : _currentIndex + 1
                : _currentIndex == 0 ? lastIndex : _currentIndex - 1,
            onWillPop: onWillPop,
          ),
        ),
      ),
      // (Route route) {
      //   return route.settings.name != '/zoom';
      // },
    );
  }
}

bool _isFirstTransitionDuration = false;

class NoAnimationCupertinoPageRoute<T> extends CupertinoPageRoute<T> {
  NoAnimationCupertinoPageRoute({
    @required WidgetBuilder builder,
    RouteSettings settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
            builder: builder,
            maintainState: maintainState,
            settings: settings,
            fullscreenDialog: fullscreenDialog);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }

  @override
  Duration get transitionDuration {
    _isFirstTransitionDuration = !_isFirstTransitionDuration;
    // transitionDuration вызывается два раза на каждую анимацию;
    // для первого вызова обнуляю значение, для второго - возвращаю.
    return _isFirstTransitionDuration
        ? const Duration(seconds: 0)
        : const Duration(milliseconds: 300);
  }
}

class NoAnimationMaterialPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationMaterialPageRoute({
    @required WidgetBuilder builder,
    RouteSettings settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
            builder: builder,
            maintainState: maintainState,
            settings: settings,
            fullscreenDialog: fullscreenDialog);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }

  @override
  Duration get transitionDuration {
    _isFirstTransitionDuration = !_isFirstTransitionDuration;
    // transitionDuration вызывается два раза на каждую анимацию;
    // для первого вызова обнуляю значение, для второго - возвращаю.
    return _isFirstTransitionDuration
        ? const Duration(seconds: 0)
        : const Duration(milliseconds: 300);
  }
}

typedef WillPopZoomCallback = Future<bool> Function(int index);

class ZoomRouteArguments {
  ZoomRouteArguments(this.item, {this.tag, this.index, this.onWillPop});

  final ItemModel item;
  final String tag;
  final int index;
  final WillPopZoomCallback onWillPop;
}
