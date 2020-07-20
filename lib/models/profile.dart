import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:minsk8/import.dart';

part 'profile.g.dart';

// TODO: удалить item из WishModel

@JsonSerializable()
class ProfileModel extends ChangeNotifier {
  final MemberModel member;
  final List<WishModel> wishes;
  final List<NotificationModel> notifications;

  ProfileModel({
    this.member,
    this.wishes,
    this.notifications,
  });

  int getWishIndex(String itemId) =>
      wishes.indexWhere((wish) => wish.itemId == itemId);

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

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}
