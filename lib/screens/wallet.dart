import 'dart:async';
import 'package:flutter/material.dart';
import 'package:extended_list/extended_list.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import "package:collection/collection.dart";
import 'package:minsk8/import.dart';

class WalletScreen extends StatefulWidget {
  @override
  WalletScreenState createState() {
    return WalletScreenState();
  }
}

class WalletScreenState extends State<WalletScreen> {
  final ShowcaseData sourceList = HomeShowcase.dataPool[0];

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

    return Scaffold(
      appBar: AppBar(
        title: Text('Движение Кармы'),
      ),
      body: PullToRefreshNotification(
        onRefresh: _onRefresh,
        maxDragOffset: kMaxDragOffset,
        child: Stack(
          children: [
            ExtendedListView.builder(
              // in case list is not full screen and remove ios Bouncing
              physics: const AlwaysScrollableClampingScrollPhysics(),
              itemBuilder: (BuildContext c, int i) {
                print(i);
                return Container(
                  alignment: Alignment.center,
                  height: 60.0,
                  child: Text('$i'),
                );
              },
              itemCount: 10,
              padding: EdgeInsets.all(0.0),
            ),
            PullToRefreshContainer((PullToRefreshScrollNotificationInfo info) {
              final offset = info?.dragOffset ?? 0.0;
              return Positioned(
                top: offset - kToolbarHeight,
                left: 0,
                right: 0,
                child: Center(child: info?.refreshWiget),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<bool> _onRefresh() {
    return Future<bool>.delayed(const Duration(seconds: 2), () {
      setState(() {});
      return true;
    });
  }
}
