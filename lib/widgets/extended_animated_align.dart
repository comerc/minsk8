import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// TODO: выкинуть, когда Google реализует свой (уже есть pullrequest)

class ExtendedAnimatedAlign extends ImplicitlyAnimatedWidget {
  /// Creates a widget that positions its child by an alignment that animates
  /// implicitly.
  ///
  /// The [alignment], [curve], and [duration] arguments must not be null.
  const ExtendedAnimatedAlign({
    Key key,
    @required this.alignment,
    this.widthFactor,
    this.heightFactor,
    this.child,
    Curve curve = Curves.linear,
    @required Duration duration,
    VoidCallback onEnd,
  })  : assert(alignment != null),
        assert(widthFactor == null || widthFactor >= 0.0),
        assert(heightFactor == null || heightFactor >= 0.0),
        super(key: key, curve: curve, duration: duration, onEnd: onEnd);

  /// How to align the child.
  ///
  /// The x and y values of the [Alignment] control the horizontal and vertical
  /// alignment, respectively. An x value of -1.0 means that the left edge of
  /// the child is aligned with the left edge of the parent whereas an x value
  /// of 1.0 means that the right edge of the child is aligned with the right
  /// edge of the parent. Other values interpolate (and extrapolate) linearly.
  /// For example, a value of 0.0 means that the center of the child is aligned
  /// with the center of the parent.
  ///
  /// See also:
  ///
  ///  * [Alignment], which has more details and some convenience constants for
  ///    common positions.
  ///  * [AlignmentDirectional], which has a horizontal coordinate orientation
  ///    that depends on the [TextDirection].
  final AlignmentGeometry alignment;

  /// If non-null, sets its width to the child's width multiplied by this factor.
  ///
  /// Can be both greater and less than 1.0 but must be positive.
  final double widthFactor;

  /// If non-null, sets its height to the child's height multiplied by this factor.
  ///
  /// Can be both greater and less than 1.0 but must be positive.
  final double heightFactor;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  @override
  _ExtendedAnimatedAlignState createState() => _ExtendedAnimatedAlignState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<AlignmentGeometry>('alignment', alignment));
    properties.add(DiagnosticsProperty<double>('widthFactor', widthFactor));
    properties.add(DiagnosticsProperty<double>('heightFactor', heightFactor));
  }
}

class _ExtendedAnimatedAlignState
    extends AnimatedWidgetBaseState<ExtendedAnimatedAlign> {
  AlignmentGeometryTween _alignment;
  Tween<double> _widthFactor;
  Tween<double> _heightFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _alignment = visitor(
            _alignment,
            widget.alignment,
            (dynamic value) =>
                AlignmentGeometryTween(begin: value as AlignmentGeometry))
        as AlignmentGeometryTween;
    if (widget.widthFactor != null) {
      _widthFactor = visitor(_widthFactor, widget.widthFactor,
              (dynamic value) => Tween<double>(begin: value as double))
          as Tween<double>;
    }
    if (widget.heightFactor != null) {
      _heightFactor = visitor(_heightFactor, widget.heightFactor,
              (dynamic value) => Tween<double>(begin: value as double))
          as Tween<double>;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _alignment.evaluate(animation),
      widthFactor: _widthFactor?.evaluate(animation),
      heightFactor: _heightFactor?.evaluate(animation),
      child: widget.child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<AlignmentGeometryTween>(
        'alignment', _alignment,
        defaultValue: null));
    description.add(DiagnosticsProperty<Tween<double>>(
        'widthFactor', _widthFactor,
        defaultValue: null));
    description.add(DiagnosticsProperty<Tween<double>>(
        'heightFactor', _heightFactor,
        defaultValue: null));
  }
}
