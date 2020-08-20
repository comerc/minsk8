import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:minsk8/import.dart';

PageRoute Function(WidgetBuilder builder) buildInitialRoute(String name) {
  return (WidgetBuilder builder) {
    final settings = RouteSettings(
      name: name,
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
  };
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
