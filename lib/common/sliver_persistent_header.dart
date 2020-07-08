import 'package:flutter/material.dart';

typedef Widget CommonSliverPersistentHeaderDelegateBuilder(
    BuildContext context, double shrinkOffset, bool overlapsContent);

class CommonSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  final double height;
  final CommonSliverPersistentHeaderDelegateBuilder builder;

  CommonSliverPersistentHeaderDelegate({this.builder, this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return builder(context, shrinkOffset, overlapsContent);
  }

  @override
  bool shouldRebuild(CommonSliverPersistentHeaderDelegate oldDelegate) {
    // TODO: оптимизировать
    return oldDelegate != this;
  }
}
