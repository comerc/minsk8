import 'package:flutter/material.dart';

// demo for: https://github.com/fluttercandies/extended_nested_scroll_view/issues/38

class NestedScrollViewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final tabBarHeight = 48.0;
    return Scaffold(
        body: NestedScrollView(
            // Setting floatHeaderSlivers to true is required in order to float
            // the outer slivers over the inner scrollable.
            floatHeaderSlivers: true,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _CommonSliverPersistentHeaderDelegate(
                    child: Container(),
                    height: statusBarHeight,
                  ),
                ),
                SliverPersistentHeader(
                  delegate: _CommonSliverPersistentHeaderDelegate(
                      child: Container(
                          color: Colors.orange[100],
                          child: Center(child: Text('Title'))),
                      height: kToolbarHeight),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _CommonSliverPersistentHeaderDelegate(
                    child: Container(
                        color: Colors.green[100],
                        child: Center(child: Text('TabBar'))),
                    height: tabBarHeight,
                  ),
                ),
                // SliverAppBar(
                //   title: const Text('Floating Nested SliverAppBar'),
                //   floating: true,
                //   expandedHeight: 200.0,
                //   forceElevated: innerBoxIsScrolled,
                // ),
              ];
            },
            body: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: 30,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 50,
                    child: Center(child: Text('Unit $index')),
                  );
                })));
  }
}

class _CommonSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  _CommonSliverPersistentHeaderDelegate({this.child, this.height});

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    //print("shouldRebuild---------------");
    return oldDelegate != this;
  }
}
