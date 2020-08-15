import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:minsk8/import.dart';

class WishButton extends StatefulWidget {
  WishButton(
    this.unit, {
    this.iconSize = kButtonIconSize,
  });

  final UnitModel unit;
  final double iconSize;

  @override
  _WishButtonState createState() {
    return _WishButtonState();
  }
}

class _WishButtonState extends State<WishButton> {
  Timer _timer;
  final _animationDuration = const Duration(milliseconds: 1000);

  @override
  void dispose() {
    _disposeTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myWishes = Provider.of<MyWishesModel>(context);
    return Tooltip(
      message: 'Wish',
      child: Material(
        child: InkWell(
          // borderRadius: BorderRadius.all(kImageBorderRadius),
          child: LikeButton(
            animationDuration: _animationDuration,
            isLiked: myWishes.getWishIndex(widget.unit.id) != -1,
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
            likeCount: null, // unit.favorites,
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
            // likeCountAnimationType: unit.favorites < 1000
            //     ? LikeCountAnimationType.part
            //     : LikeCountAnimationType.none,
            onTap: _onTap,
          ),
          onTap: () {},
        ),
      ),
    );
  }

  void _disposeTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<bool> _onTap(bool isLiked) async {
    if (_timer != null) {
      return isLiked;
    }
    _timer = Timer(isLiked ? Duration.zero : _animationDuration, () {
      _disposeTimer();
      updateWish(context, isLiked, widget.unit);
    });
    return !isLiked;
  }
}

void updateWish(BuildContext context, bool isLiked, UnitModel unit) {
  final myWishes = Provider.of<MyWishesModel>(context, listen: false);
  final index = myWishes.getWishIndex(unit.id);
  final currentIsLiked = index != -1;
  if (isLiked != currentIsLiked) {
    return;
  }
  final wish = isLiked
      ? myWishes.wishes[index] // index check with currentIsLiked
      : WishModel(
          createdAt: DateTime.now(),
          unitId: unit.id,
        );
  myWishes.updateWish(index, wish, !isLiked);
  final client = GraphQLProvider.of(context).value;
  final options = MutationOptions(
    documentNode: isLiked ? Mutations.deleteWish : Mutations.insertWish,
    variables: {'unit_id': unit.id},
    fetchPolicy: FetchPolicy.noCache,
  );
  client
      .mutate(options)
      .timeout(kGraphQLMutationTimeoutDuration)
      .then((QueryResult result) {
    if (result.hasException) {
      throw result.exception;
    }
  }).catchError((error) {
    final index = myWishes.getWishIndex(unit.id);
    myWishes.updateWish(index, wish, isLiked);
    print(error);
  });
}
