import 'package:flutter/material.dart';

typedef CommonSliverPersistentHeaderDelegateBuilder = Widget Function(
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
    // TODO: оптимизировать https://codewithandrea.com/tips/2020-08-13-dart-flutter-easy-wins-8-14/#14-want-to-auto-generate-hashcode-==-and-tostring-implementations-for-your-classes?-use-the-equatable-package
    return oldDelegate != this;
  }
}
