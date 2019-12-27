import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'profile.g.dart';

@JsonSerializable()
class ProfileModel {
  final String memberId;
  final String nickname;
  final double locationLatitude;
  final double locationLongitude;
  final int money;
  final List<PayModel> wallet;
  final List<ItemModel> myItems;
  final List<ItemModel> whishes;
  final List<ItemModel> underway;

  ProfileModel(
    this.memberId,
    this.nickname,
    this.locationLatitude,
    this.locationLongitude,
    this.money,
    this.wallet,
    this.myItems,
    this.whishes,
    this.underway,
  );

  avatarUrl() {
    return 'https://example.com/avatars/?id=$memberId';
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}
