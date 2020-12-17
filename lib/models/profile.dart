import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:minsk8/import.dart';

part 'profile.g.dart';

@JsonSerializable()
class ProfileModel extends ChangeNotifier {
  ProfileModel({
    this.member,
    this.balance,
  });

  final MemberModel member;
  final int balance;

  static ProfileModel fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}

@JsonSerializable(createFactory: false)
class MemberData {
  MemberData({this.displayName, this.imageUrl});

  final String displayName;
  final String imageUrl;

  Map<String, dynamic> toJson() => _$MemberDataToJson(this);
}
