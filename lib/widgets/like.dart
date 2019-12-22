import 'package:minsk8/import.dart';
import 'package:like_button/like_button.dart';

Widget buildLike(TuChongItem item) {
  return LikeButton(
    size: 18.0,
    isLiked: item.isFavorite,
    likeCount: item.favorites,
    countBuilder: (int count, bool isLiked, String text) {
      final color = isLiked ? Colors.pinkAccent : Colors.grey;
      Widget result;
      if (count == 0) {
        result = Text(
          "love",
          style: TextStyle(color: color, fontSize: fontSize),
        );
      } else
        result = Text(
          count >= 1000 ? (count / 1000.0).toStringAsFixed(1) + "k" : text,
          style: TextStyle(color: color, fontSize: fontSize),
        );
      return result;
    },
    likeCountAnimationType: item.favorites < 1000
        ? LikeCountAnimationType.part
        : LikeCountAnimationType.none,
    onTap: (bool isLiked) => _onTap(isLiked, item),
  );
}

Future<bool> _onTap(bool isLiked, TuChongItem item) {
  // send your request here
  return Future<bool>.delayed(Duration(milliseconds: 50), () {
    item.isFavorite = !item.isFavorite;
    item.favorites = item.isFavorite ? item.favorites + 1 : item.favorites - 1;
    return item.isFavorite;
  });
}
