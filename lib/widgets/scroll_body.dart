import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

class ScrollBody extends StatelessWidget {
  ScrollBody({this.child});

  final Widget child;

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
    return ScrollBodyBuilder(
      builder: (BuildContext context, ScrollController controller) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              controller: controller,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: child,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ScrollBodyBuilder extends StatefulWidget {
  ScrollBodyBuilder({this.builder});

  final Widget Function(BuildContext context, ScrollController controller)
      builder;

  @override
  _ScrollBodyBuilderState createState() {
    return _ScrollBodyBuilderState();
  }
}

class _ScrollBodyBuilderState extends State<ScrollBodyBuilder> {
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

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _controller);
  }

  void _scrollListener() {
    if (_appBarModel.isElevation != (_controller.offset > 1)) {
      _appBarModel.isElevation = !_appBarModel.isElevation;
    }
  }
}
