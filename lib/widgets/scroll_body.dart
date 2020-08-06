import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

class ScrollBody extends StatefulWidget {
  ScrollBody({this.child, this.withIntrinsicHeight = true});

  final Widget child;
  final bool withIntrinsicHeight;

  @override
  _ScrollBodyState createState() {
    return _ScrollBodyState();
  }
}

class _ScrollBodyState extends State<ScrollBody> {
  Future _future;
  ScrollController _controller;
  var _isElevation = false;

  @override
  void initState() {
    super.initState();
    _future = _reset();
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
    return FutureBuilder(
      // https://github.com/flutter/flutter/issues/11426#issuecomment-414047398
      future: _future,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return LayoutBuilder(
            builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                controller: _controller,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: widget.withIntrinsicHeight
                      ? IntrinsicHeight(
                          child: widget.child,
                        )
                      : widget.child,
                ),
              );
            },
          );
        }
        return Container();
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

  Future<void> _reset() async {
    final appBarModel = Provider.of<AppBarModel>(context, listen: false);
    appBarModel.isElevation = false;
  }
}
