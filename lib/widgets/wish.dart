import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:minsk8/import.dart';

class Wish extends StatefulWidget {
  final ItemModel item;

  Wish(this.item);

  @override
  _WishState createState() {
    return _WishState(this.item.id);
  }
}

class _WishState extends State<Wish> {
  final String itemId;

  _WishState(this.itemId);

  get _isLiked {
    assert(mounted);
    return widget.item.isMemberWish;
  }

  set _isLiked(value) {
    assert(mounted);
    widget.item.isMemberWish = value;
  }

  @override
  Widget build(BuildContext context) {
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
            isLiked: _isLiked,
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
            onTap: (bool isLiked) => _onTap(context, isLiked),
          ),
          onTap: () {},
        ),
      ),
    );
  }

  Future<bool> _onTap(BuildContext context, bool isLiked) async {
    _isLiked = !isLiked;
    _setWishToMember(!isLiked);
    // print('item.id: ${item.id}');
    // print('member.id: $memberId');
    final client = GraphQLProvider.of(context).value;
    final options = MutationOptions(
      documentNode: isLiked ? Mutations.deleteWish : Mutations.insertWish,
      variables: {'item_id': itemId},
      // onCompleted: (data) => print('>>onCompleted: $data'),
      // update: (Cache cache, QueryResult result) =>
      //     print('>>update: ${result.hasException}'),
      // onError: (OperationException error) => print('>>onError: $error'),
    );
    client.mutate(options).then((QueryResult result) {
      print('>>then: ${result.hasException}');
      if (result.hasException) {
        throw result.exception;
      }
      print('result.loading: ${result.loading}');
      print('result.data: ${result.data}');
      // client.cache.write()
    }).catchError((error) {
      // TODO: сообщать об ошибке и откатывать локальные данные
      // client.cache.write()
      // тут нельзя обращаться к _isLiked, только к локальной isLiked
      _setWishToMember(isLiked);
      if (mounted) {
        setState(() {
          _isLiked = isLiked;
        });
      }
      print(error);
    });
    return !isLiked;
  }

  _setWishToMember(isLiked) {
    if (isLiked) {
      memberWishes.add(itemId);
    } else {
      memberWishes.remove(itemId);
    }
  }
}
