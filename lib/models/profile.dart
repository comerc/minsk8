import 'package:built_collection/built_collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'profile.g.dart';

@CopyWith()
@JsonSerializable()
class ProfileModel extends Equatable {
  ProfileModel({
    this.balance,
    this.member,
    this.wishes,
    this.blocks,
  });

  final int balance;
  final MemberModel member;
  final BuiltList<WishModel> wishes;
  final BuiltList<BlockModel> blocks;

  int getWishIndex(String unitId) =>
      wishes.indexWhere((WishModel wish) => wish.unitId == unitId);

  int getBlockIndex(String memberId) =>
      blocks.indexWhere((BlockModel block) => block.memberId == memberId);

  @override
  List<Object> get props => [
        balance,
        member,
        wishes,
        blocks,
      ];

  static ProfileModel fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}
