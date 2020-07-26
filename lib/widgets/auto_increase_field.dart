import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

class AutoIncreaseField extends StatefulWidget {
  AutoIncreaseField({this.unit});

  final UnitModel unit;

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
    _controller =
        AnimationController(duration: const Duration(seconds: 4), vsync: this);
    _animation = Tween<double>(begin: 0, end: 100).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 1),
        Tooltip(
          message:
              _value ? 'Выключить автоповышение' : 'Включить автоповышение',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              child: SwitchListTile.adaptive(
                title: Text('Автоповышение'),
                value: _value,
                onChanged: _handleChanged,
              ),
            ),
          ),
        ),
        _AnimatedSizedBox(
          animation: _animation,
          visible: _visible,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              '1111',
            ),
          ),
        ),
        Divider(height: 1),
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
  _AnimatedSizedBox(
      {Key key, Animation<double> animation, this.visible, this.child})
      : super(key: key, listenable: animation);

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return SizedBox(
      height: animation.value,
      child: visible ? child : null,
    );
  }
}
