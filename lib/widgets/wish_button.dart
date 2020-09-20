import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:bot_toast/bot_toast.dart';
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
            isLiked: myWishes.has(widget.unit.id),
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
      final myWishes = Provider.of<MyWishesModel>(context, listen: false);
      _optimisticUpdateWish(
        myWishes,
        unit: widget.unit,
        value: !isLiked,
      );
    });
    return !isLiked;
  }
}

Future<void> _queue = Future.value();

void _optimisticUpdateWish(MyWishesModel myWishes,
    {UnitModel unit, bool value}) {
  final oldUpdatedAt = myWishes.updateWish(
    unitId: unit.id,
    value: value,
  );
  // final client = GraphQLProvider.of(context).value;
  final options = MutationOptions(
    documentNode: Mutations.upsertWish,
    variables: {
      'unit_id': unit.id,
      'value': value,
    },
    fetchPolicy: FetchPolicy.noCache,
  );
  _queue = _queue.then((_) {
    return client
        .mutate(options)
        .timeout(kGraphQLMutationTimeoutDuration)
        .then((QueryResult result) {
      if (result.hasException) {
        throw result.exception;
      }
      final json = result.data['insert_wish_one'];
      myWishes.updateWish(
        unitId: unit.id,
        value: value,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
    });
  }).catchError((error) {
    debugPrint(error.toString());
    myWishes.updateWish(
      unitId: unit.id,
      value: oldUpdatedAt != null,
      updatedAt: oldUpdatedAt,
    );
    BotToast.showNotification(
      title: (_) => Text(
        value
            ? 'Не удалось сохранить желание для "${unit.text}"'
            : 'Не удалось удалить желание для "${unit.text}"',
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
      trailing: (Function close) => FlatButton(
        child: Text(
          'ПОВТОРИТЬ',
          style: TextStyle(
            fontSize: kFontSize,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        onLongPress: () {}, // чтобы сократить время для splashColor
        onPressed: () {
          close();
          _optimisticUpdateWish(myWishes, unit: unit, value: value);
        },
      ),
    );
  });
}
