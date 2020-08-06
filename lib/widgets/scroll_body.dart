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
  ScrollController _controller;
  AppBarModel _appBarModel;

  @override
  void initState() {
    super.initState();
    _appBarModel = Provider.of<AppBarModel>(context, listen: false);
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback(_onAfterBuild);
  }

  void _onAfterBuild(Duration timeStamp) async {
    _appBarModel.isElevation = false;
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    _controller.dispose();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return FutureBuilder(
  //     // https://github.com/flutter/flutter/issues/11426#issuecomment-414047398
  //     future: _future,
  //     builder: (BuildContext context, AsyncSnapshot snapshot) {
  //       if (snapshot.connectionState == ConnectionState.done) {
  //         return LayoutBuilder(
  //           builder:
  //               (BuildContext context, BoxConstraints viewportConstraints) {
  //             return SingleChildScrollView(
  //               controller: _controller,
  //               child: ConstrainedBox(
  //                 constraints: BoxConstraints(
  //                   minHeight: viewportConstraints.maxHeight,
  //                 ),
  //                 child: widget.withIntrinsicHeight
  //                     ? IntrinsicHeight(
  //                         child: widget.child,
  //                       )
  //                     : widget.child,
  //               ),
  //             );
  //           },
  //         );
  //       }
  //       return Container();
  //     },
  //   );
  // }

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

  void _scrollListener() {
    if (_appBarModel.isElevation != (_controller.offset > 1)) {
      _appBarModel.isElevation = !_appBarModel.isElevation;
    }
  }
}
