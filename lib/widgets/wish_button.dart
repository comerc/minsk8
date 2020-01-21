import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Wish',
      child: Material(
        child: InkWell(
          // borderRadius: BorderRadius.all(kImageBorderRadius),
          child: LikeButton(
            isLiked: _profileWishIndex != -1,
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
            onTap: _onTap,
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
