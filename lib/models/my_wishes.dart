import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:minsk8/import.dart';

part 'my_wishes.g.dart';

@JsonSerializable()
class MyWishesModel extends ChangeNotifier {
  MyWishesModel({
    this.wishes,
  });

  final List<WishModel> wishes;

  int getWishIndex(String unitId) =>
      wishes.indexWhere((wish) => wish.unitId == unitId);

  void updateWish(int index, WishModel wish, bool isLiked) {
    if (isLiked) {
      if (index == -1) {
        wishes.add(wish);
        notifyListeners();
      }
    } else {
      if (index != -1) {
        wishes.removeAt(index);
        notifyListeners();
      }
    }
  }

  factory MyWishesModel.fromJson(Map<String, dynamic> json) =>
      _$MyWishesModelFromJson(json);

  Map<String, dynamic> toJson() => _$MyWishesModelToJson(this);
}
