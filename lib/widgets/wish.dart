import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:minsk8/import.dart';

// class Wish extends

Widget buildWish(ItemModel item) {
  return Tooltip(
    message: 'Wish',
    child: Material(
      child: InkWell(
        borderRadius: BorderRadius.all(kImageBorderRadius),
        child: LikeButton(
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 16.3,
          ),
          size: 18.0,
          isLiked: item.isMemberWish,
          likeBuilder: (bool isLiked) {
            if (isLiked) {
              return Icon(
                Icons.favorite,
                color: Colors.pinkAccent,
                size: 18,
              );
            }
            return Icon(
              Icons.favorite_border,
              color: Colors.black,
              size: 18,
            );
          },
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
          //           ? (count / 1000.0).toStringAsFixed(1) + "k"
          //           : text,
          //       style: TextStyle(color: color, fontSize: kFontSize),
          //     );
          //   return result;
          // },
          // likeCountAnimationType: item.favorites < 1000
          //     ? LikeCountAnimationType.part
          //     : LikeCountAnimationType.none,
          onTap: (bool isLiked) => _onTap(isLiked, item),
        ),
        onTap: () {},
      ),
    ),
  );
}

Future<bool> _onTap(bool isLiked, ItemModel item) async {
  // send your request here
  // return Future<bool>.delayed(Duration(milliseconds: 50), () {
  item.isMemberWish = !isLiked;
  if (item.isMemberWish) {
    memberWishes.add(item.id);
    // final client = GraphQLProvider.of(context).value;
    // //to show loading more clearly, in your app,remove this
    // // await Future.delayed(Duration(milliseconds: 500));
    // final result = await client.query(options);
    // client.cache.write()
  } else {
    memberWishes.remove(item.id);
  }
  // item.isFavorite = !item.isFavorite;
  // item.favorites = item.isFavorite ? item.favorites + 1 : item.favorites - 1;
  // return item.isFavorite;
  return item.isMemberWish;
  // });
}
