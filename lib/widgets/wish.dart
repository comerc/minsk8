import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:minsk8/import.dart';

class Wish extends StatelessWidget {
  final ItemModel item;

  Wish(this.item);

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
            onTap: (bool isLiked) => _onTap(context, isLiked, item),
          ),
          onTap: () {},
        ),
      ),
    );
  }

  Future<bool> _onTap(
      BuildContext context, bool isLiked, ItemModel item) async {
    item.isMemberWish = !isLiked;
    if (item.isMemberWish) {
      memberWishes.add(item.id);
    } else {
      memberWishes.remove(item.id);
    }
    final client = GraphQLProvider.of(context).value;
    final options = MutationOptions(
      documentNode:
          item.isMemberWish ? Mutations.insertWish : Mutations.deleteWish,
      variables: {'item_id': item.id},
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
      print(error);
    });
    return item.isMemberWish;
  }
}
