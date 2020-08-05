import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

class ScrollBody extends StatefulWidget {
  ScrollBody({this.child});

  final Widget child;

  @override
  _ScrollBodyState createState() {
    return _ScrollBodyState();
  }
}

class _ScrollBodyState extends State<ScrollBody> {
  ScrollController _controller;
  var _isElevation = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          controller: _controller,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: widget.child,
            ),
          ),
        );
      },
    );
  }

  void _scrollListener() {
    if (_isElevation != (_controller.offset > 1)) {
      _isElevation = !_isElevation;
      final appBarModel = Provider.of<AppBarModel>(context, listen: false);
      appBarModel.isElevation = _isElevation;
    }
  }
}
