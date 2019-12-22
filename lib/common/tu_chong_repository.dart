import 'dart:async';
// import 'dart:convert' show json;
import 'package:http_client_helper/http_client_helper.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:minsk8/import.dart';

class TuChongRepository extends LoadingMoreBase<TuChongItem> {
  // TODO:
  final loadParams;
  int _pageIndex = 1;
  bool _hasMore = true;
  bool _forceRefresh = false;

  TuChongRepository(this.loadParams);

  @override
  bool get hasMore => (_hasMore && this.length < 30) || _forceRefresh;

  @override
  Future<bool> refresh([bool clearBeforeRequest = false]) async {
    _hasMore = true;
    _pageIndex = 1;
    //force to refresh list when you don't want clear list before request
    //for the case, if your list already has 20 items.
    _forceRefresh = !clearBeforeRequest;
    final result = await super.refresh(clearBeforeRequest);
    _forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    String url = "";
    if (this.length == 0) {
      url = "https://api.tuchong.com/feed-app";
    } else {
      int lastPostId = this[this.length - 1].postId;
      url =
          "https://api.tuchong.com/feed-app?post_id=$lastPostId&page=$_pageIndex&type=loadmore";
    }
    bool isSuccess = false;
    try {
      //to show loading more clearly, in your app,remove this
      await Future.delayed(Duration(milliseconds: 500));

      final result = await HttpClientHelper.get(url);

      final source = TuChongSource(result.body);
      if (_pageIndex == 1) {
        this.clear();
      }
      for (final item in source.feedList) {
        if (item.hasImage && !this.contains(item) && hasMore) this.add(item);
      }

      _hasMore = source.feedList.length != 0;
      _pageIndex++;
//      this.clear();
//      _hasMore=false;
      isSuccess = true;
    } catch (exception, stack) {
      isSuccess = false;
      print(exception);
      print(stack);
    }
    return isSuccess;
  }
}
