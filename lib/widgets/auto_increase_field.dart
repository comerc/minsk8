import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class AutoIncreaseField extends StatefulWidget {
  AutoIncreaseField({this.child, this.height});

  final Widget child;
  final double height;

  @override
  _AutoIncreaseFieldState createState() {
    return _AutoIncreaseFieldState();
  }
}

class _AutoIncreaseFieldState extends State<AutoIncreaseField>
    with SingleTickerProviderStateMixin {
  var _value = false;
  var _visible = false;
  Animation<double> _animation;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    _animation =
        Tween<double>(begin: 0, end: widget.height).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Tooltip(
          message:
              _value ? 'Выключить автоповышение' : 'Включить автоповышение',
          child: SwitchListTile.adaptive(
            dense: true,
            title: Text(
              'Автоповышение ставки',
              // такой же стиль для 'Самовывоз'
              style: TextStyle(
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            value: _value,
            onChanged: _handleChanged,
          ),
        ),
        _AnimatedSizedBox(
          animation: _animation,
          child: _visible
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  // TODO: _AnimatedOpacity
                  child: widget.child,
                )
              : null,
        ),
      ],
    );
  }

  void _handleChanged(bool value) async {
    if (value) {
      setState(() {
        _value = true;
      });
      await _controller.forward();
      setState(() {
        _visible = true;
      });
    } else {
      setState(() {
        _value = false;
        _visible = false;
      });
      // ignore: unawaited_futures
      _controller.reverse();
    }
  }
}

class _AnimatedSizedBox extends AnimatedWidget {
  _AnimatedSizedBox({
    Key key,
    Animation<double> animation,
    this.child,
  }) : super(key: key, listenable: animation);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return SizedBox(
      height: animation.value,
      child: child,
    );
  }
}
