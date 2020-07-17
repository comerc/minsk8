import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
// import 'package:extended_list/extended_list.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import "package:collection/collection.dart";
import 'package:minsk8/import.dart';

// TODO: ExtendedListView? https://github.com/fluttercandies/extended_list/issues/5

class WalletScreen extends StatelessWidget {
  // final List _elements = [
  //   {'name': 'Basic Java', 'group': 'Java'},
  //   {'name': 'PHP', 'group': 'Java'},
  //   {'name': 'BLoC Pattern', 'group': 'Flutter'},
  //   {'name': 'Lifecycle Android', 'group': 'Android'},
  //   {'name': 'Basic Flutter', 'group': 'Flutter'},
  //   {'name': 'Inheritance', 'group': 'Java'},
  // ];

  // final List _elements = <Element>[
  //   Element(DateTime(2020, 6, 24, 18), 'Got to gym', Icons.fitness_center),
  //   Element(DateTime(2020, 6, 24, 9), 'Work', Icons.work),
  //   Element(DateTime(2020, 6, 25, 8), 'Buy groceries', Icons.shopping_basket),
  //   Element(DateTime(2020, 6, 25, 16), 'Cinema', Icons.movie),
  //   Element(DateTime(2020, 6, 25, 20), 'Eat', Icons.fastfood),
  //   Element(DateTime(2020, 6, 26, 12), 'Car wash', Icons.local_car_wash),
  //   Element(DateTime(2020, 6, 27, 12), 'Car wash', Icons.local_car_wash),
  //   Element(DateTime(2020, 6, 27, 13), 'Car wash', Icons.local_car_wash),
  //   Element(DateTime(2020, 6, 27, 14), 'Car wash', Icons.local_car_wash),
  //   Element(DateTime(2020, 6, 27, 15), 'Car wash', Icons.local_car_wash),
  //   Element(DateTime(2020, 6, 28, 12), 'Car wash', Icons.local_car_wash),
  //   Element(DateTime(2020, 6, 29, 12), 'Car wash', Icons.local_car_wash),
  //   Element(DateTime(2020, 6, 29, 12), 'Car wash', Icons.local_car_wash),
  //   Element(DateTime(2020, 6, 30, 12), 'Car wash', Icons.local_car_wash),
  // ];

  @override
  Widget build(BuildContext context) {
    final dataSet = [
      {
        "time": "2020-06-16T10:31:12.000Z",
        "message": "Message1",
      },
      {
        "time": "2020-06-16T10:29:35.000Z",
        "message": "Message2",
      },
      {
        "time": "2020-06-15T09:41:18.000Z",
        "message": "Message3",
      },
    ];
    final items = [];
    var groupByDate = groupBy(dataSet, (obj) => obj['time'].substring(0, 10));
    groupByDate.forEach((date, list) {
      // Header
      // print('${date}:');
      items.add({'date': date});
      // Group
      list.forEach((listItem) {
        // List item
        // print('${listItem["time"]}, ${listItem["message"]}');
        items.add(listItem);
      });
      // day section divider
      // print('\n');
    });

    // int listlength = 50;
    const maxDragOffset = 100.0;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Движение Кармы'),
      // ),
      appBar: PreferredSize(
        child: Container(
          color: Colors.blue,
        ),
        preferredSize: Size.zero, // hack
      ),
      body: PullToRefreshNotification(
        onRefresh: _onRefresh,
        maxDragOffset: maxDragOffset,
        child: GlowNotificationWidget(
          CustomScrollView(
            // in case list is not full screen and remove ios Bouncing
            physics: const AlwaysScrollableClampingScrollPhysics(),
            slivers: <Widget>[
              PullToRefreshContainer(
                (PullToRefreshScrollNotificationInfo info) {
                  return SliverPersistentHeader(
                    pinned: true,
                    delegate: CommonSliverPersistentHeaderDelegate(
                      builder: (BuildContext context, double shrinkOffset,
                          bool overlapsContent) {
                        final offset = info?.dragOffset ?? 0.0;
                        return Stack(
                          fit: StackFit.expand,
                          overflow: Overflow.visible,
                          children: [
                            Positioned(
                              top: shrinkOffset + offset,
                              left: 0,
                              right: 0,
                              child: Center(child: info?.refreshWiget),
                            ),
                            AppBar(title: Text('Движение Кармы')),
                          ],
                        );
                      },
                      height: kToolbarHeight,
                    ),
                  );
                },
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final item = items[index];
                    if (item['date'] != null) {
                      return Container(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        alignment: Alignment.topCenter,
                        child: Text(item['date']),
                      );
                    }
                    return Container(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        "${item['time']} ${item['message']}",
                        // style: const TextStyle(fontSize: 15.0),
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ],
          ),
          showGlowTrailing: true,
        ),
      ),
    );
  }

  Future<bool> _onRefresh() {
    return Future<bool>.delayed(const Duration(seconds: 2), () {
      return true;
    });
  }
}

class Element implements Comparable {
  DateTime date;
  String name;
  IconData icon;

  Element(this.date, this.name, this.icon);

  @override
  int compareTo(other) {
    return date.compareTo(other.date);
  }
}

class RefreshLogo extends StatefulWidget {
  const RefreshLogo({
    Key key,
    @required this.mode,
    @required this.offset,
  }) : super(key: key);
  final double offset;
  final RefreshIndicatorMode mode;

  @override
  _RefreshLogoState createState() => _RefreshLogoState();
}

class _RefreshLogoState extends State<RefreshLogo>
    with TickerProviderStateMixin {
  AnimationController rotateController;
  CurvedAnimation rotateCurveAnimation;
  Animation<double> rotateAnimation;
  double angle = 0.0;

  bool animating = false;

  @override
  void initState() {
    rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    rotateCurveAnimation = CurvedAnimation(
      parent: rotateController,
      curve: Curves.ease,
    );
    rotateAnimation =
        Tween<double>(begin: 0.0, end: 2.0).animate(rotateCurveAnimation);
    super.initState();
  }

  void startAnimate() {
    animating = true;
    rotateController.repeat();
  }

  void stopAnimate() {
    animating = false;
    rotateController
      ..stop()
      ..reset();
  }

  Widget get logo => Image.asset(
        'assets/lollipop-without-stick.png',
        height: math.min(widget.offset, 50),
      );

  @override
  Widget build(BuildContext context) {
    if (widget.mode == null) {
      return Container();
    }
    if (!animating && widget.mode == RefreshIndicatorMode.refresh) {
      startAnimate();
    } else if (widget.offset < 10.0 &&
        animating &&
        widget.mode != RefreshIndicatorMode.refresh) {
      stopAnimate();
    }
    return Container(
      width: math.min(widget.offset, 50),
      height: math.min(widget.offset, 50),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey,
          ),
        ],
      ),
      child: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Image.asset(
              'assets/lollipop.png',
            ),
          ),
          if (animating)
            RotationTransition(
              turns: rotateAnimation,
              child: logo,
            )
          else
            logo,
        ],
      ),
    );
  }
}
