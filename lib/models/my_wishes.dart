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

  int _getWishIndex(String unitId) =>
      wishes.indexWhere((wish) => wish.unitId == unitId);

  bool has(String unitId) => _getWishIndex(unitId) != -1;

  DateTime updateWish({String unitId, bool value, DateTime updatedAt}) {
    final index = _getWishIndex(unitId);
    final oldUpdatedAt = index == -1 ? null : wishes[index].updatedAt;
    final wish = WishModel(
      updatedAt: updatedAt ?? DateTime.now(),
      unitId: unitId,
    );
    if (value) {
      if (index == -1) {
        wishes.add(wish);
      } else {
        wishes[index] = wish;
      }
      notifyListeners();
    } else {
      if (index != -1) {
        wishes.removeAt(index);
        notifyListeners();
      }
    }
    return oldUpdatedAt;
  }

  static MyWishesModel fromJson(Map<String, dynamic> json) =>
      _$MyWishesModelFromJson(json);

  Map<String, dynamic> toJson() => _$MyWishesModelToJson(this);
}
