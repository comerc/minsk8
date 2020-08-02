import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:minsk8/import.dart';

//you can use IndicatorWidget or build yourself widget
//in this demo, we define all status.
Widget buildListIndicator({
  BuildContext context,
  IndicatorStatus status,
  LoadingMoreBase sourceList,
}) {
  //if your list is sliver list ,you should build sliver indicator for it
  //isSliver=true, when use it in sliver list
  var isSliver = true;
  Widget result;
  switch (status) {
    case IndicatorStatus.none:
      result = Container(height: 0);
      break;
    case IndicatorStatus.loadingMoreBusying:
      result = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            // margin: EdgeInsets.only(right: 5),
            height: 15,
            width: 15,
            child: buildProgressIndicator(context),
          ),
          // Text("正在加载...不要着急")
        ],
      );
      result = _buildBackground(false, result);
      break;
    case IndicatorStatus.fullScreenBusying:
      result = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            // margin: EdgeInsets.only(right: 5),
            height: 30,
            width: 30,
            child: buildProgressIndicator(context),
          ),
          // Text("正在加载...不要着急")
        ],
      );
      result = _buildBackground(true, result);
      if (isSliver) {
        result = SliverFillRemaining(
          child: result,
        );
      } else {
        result = CustomScrollView(
          slivers: <Widget>[
            SliverFillRemaining(
              child: result,
            )
          ],
        );
      }
      break;
    case IndicatorStatus.error:
      result = Text(
        // "好像出现了问题呢？",
        'Кажется, что-то пошло не так?',
      );
      result = _buildBackground(false, result);
      result = Material(
        child: InkWell(
          onLongPress: () {}, // чтобы сократить время для splashColor
          onTap: () {
            sourceList.errorRefresh();
          },
          child: result,
        ),
      );
      break;
    case IndicatorStatus.fullScreenError:
      result = Text(
        // "好像出现了问题呢？",
        'Кажется, что-то пошло не так?',
      );
      result = _buildBackground(true, result);
      result = Material(
        child: InkWell(
          onLongPress: () {}, // чтобы сократить время для splashColor
          onTap: () {
            sourceList.errorRefresh();
          },
          child: result,
        ),
      );
      if (isSliver) {
        result = SliverFillRemaining(
          child: result,
        );
      } else {
        result = CustomScrollView(
          slivers: <Widget>[
            SliverFillRemaining(
              child: result,
            )
          ],
        );
      }
      break;
    case IndicatorStatus.noMoreLoad:
      // result = Text("没有更多的了。。不要拖了");
      result = Container();
      result = _buildBackground(false, result);
      break;
    case IndicatorStatus.empty:
      // result = EmptyWidget("这里是空气！");
      result = Text('Нет данных');
      result = _buildBackground(true, result);
      if (isSliver) {
        result = SliverFillRemaining(
          // SliverToBoxAdapter( // заменил
          child: result,
        );
      } else {
        result = CustomScrollView(
          slivers: <Widget>[
            SliverFillRemaining(
              child: result,
            )
          ],
        );
      }
      break;
  }
  return result;
}

Widget _buildBackground(bool full, Widget child) {
  return Container(
      padding: EdgeInsets.only(bottom: 200),
      width: double.infinity,
      height: full ? double.infinity : kNavigationBarHeight * 2,
      child: child,
      color: Colors.transparent,
      alignment: full ? Alignment.center : Alignment.topCenter);
}
