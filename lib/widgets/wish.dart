import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:minsk8/import.dart';

class Wish extends StatefulWidget {
  final ItemModel item;

  Wish(this.item);

  @override
  _WishState createState() {
    return _WishState();
  }
}

class _WishState extends State<Wish> {
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Wish',
      child: Material(
        child: InkWell(
          // borderRadius: BorderRadius.all(kImageBorderRadius),
          child: LikeButton(
            size: 36.0,
            padding: EdgeInsets.symmetric(
              horizontal: 6.0,
            ),
            isLiked: _profileWishIndex != -1,
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
            onTap: (bool isLiked) => _onTap(isLiked),
          ),
          onTap: () {},
        ),
      ),
    );
  }

  Future<bool> _onTap(bool isLiked) async {
    final createdAt =
        isLiked ? profile.wishes[_profileWishIndex].createdAt : DateTime.now();
    _updateWishInProfile(!isLiked, createdAt);
    final client = GraphQLProvider.of(context).value;
    final options = MutationOptions(
      documentNode: isLiked ? Mutations.deleteWish : Mutations.insertWish,
      variables: {'item_id': widget.item.id},
    );
    client.mutate(options).then((QueryResult result) {
      if (result.hasException) {
        throw result.exception;
      }
    }).catchError((error) {
      _updateWishInProfile(isLiked, createdAt);
      if (mounted) {
        setState(() {});
      }
      print(error);
    });
    return !isLiked;
  }

  get _profileWishIndex =>
      profile.wishes.indexWhere((wish) => wish.item.id == widget.item.id);

  _updateWishInProfile(isLiked, createdAt) {
    final index = _profileWishIndex;
    if (isLiked) {
      if (index == -1) {
        profile.wishes.add(
          WishModel(
            createdAt: createdAt,
            item: widget.item,
          ),
        );
      }
    } else {
      if (index != -1) {
        profile.wishes.remove(index);
      }
    }
  }
}
