import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:minsk8/import.dart';

class WishButton extends StatefulWidget {
  WishButton(
    this.item, {
    this.iconSize = kButtonIconSize,
  });

  final ItemModel item;
  final double iconSize;

  @override
  _WishButtonState createState() {
    return _WishButtonState();
  }
}

class _WishButtonState extends State<WishButton> {
  Timer _timer;
  final animationDuration = Duration(milliseconds: 1000);

  @override
  void dispose() {
    _disposeTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileModel>(context);
    return Tooltip(
      message: 'Wish',
      child: Material(
        child: InkWell(
          // borderRadius: BorderRadius.all(kImageBorderRadius),
          child: LikeButton(
            animationDuration: animationDuration,
            isLiked: profile.getWishIndex(widget.item.id) != -1,
            likeBuilder: (bool isLiked) {
              if (isLiked) {
                return Icon(
                  Icons.favorite,
                  color: Colors.pinkAccent,
                  size: widget.iconSize,
                );
              }
              return Icon(
                Icons.favorite_border,
                color: Colors.black.withOpacity(0.8),
                size: widget.iconSize,
              );
            },
            likeCountPadding: null,
            likeCount: null, // item.favorites,
            // countBuilder: (int count, bool isLiked, String text) {
            //   final color = isLiked ? Colors.pinkAccent : Colors.grey;
            //   Widget result;
            //   if (count == 0) {
            //     result = Text(
            //       "love",
            //       style: TextStyle(color: color, fontSize: kFontSize),
            //     );
            //   } else
            //     result = Text(
            //       count >= 1000
            //           ? (count / 1000).toStringAsFixed(1) + "k"
            //           : text,
            //       style: TextStyle(color: color, fontSize: kFontSize),
            //     );
            //   return result;
            // },
            // likeCountAnimationType: item.favorites < 1000
            //     ? LikeCountAnimationType.part
            //     : LikeCountAnimationType.none,
            onTap: _onTap,
          ),
          onTap: () {},
        ),
      ),
    );
  }

  _disposeTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<bool> _onTap(bool isLiked) async {
    if (_timer != null) {
      return isLiked;
    }
    _timer = Timer(isLiked ? Duration.zero : animationDuration, () {
      _disposeTimer();
      updateWish(context, isLiked, widget.item);
    });
    return !isLiked;
  }
}

void updateWish(context, isLiked, item) {
  final profile = Provider.of<ProfileModel>(context, listen: false);
  final index = profile.getWishIndex(item.id);
  final currentIsLiked = index != -1;
  if (isLiked != currentIsLiked) {
    return;
  }
  final wish = isLiked
      ? profile.wishes[index] // index check with currentIsLiked
      : WishModel(
          createdAt: DateTime.now(),
          itemId: item.id,
        );
  profile.updateWish(index, wish, !isLiked);
  final GraphQLClient client = GraphQLProvider.of(context).value;
  final options = MutationOptions(
    documentNode: isLiked ? Mutations.deleteWish : Mutations.insertWish,
    variables: {'item_id': item.id},
    fetchPolicy: FetchPolicy.noCache,
  );
  client
      .mutate(options)
      .timeout(Duration(seconds: kGraphQLMutationTimeout))
      .then((QueryResult result) {
    if (result.hasException) {
      throw result.exception;
    }
  }).catchError((error) {
    final index = profile.getWishIndex(item.id);
    profile.updateWish(index, wish, isLiked);
    print(error);
  });
}
