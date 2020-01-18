import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'member.g.dart';

// TODO:  https://robohash.org/

@JsonSerializable()
class MemberModel {
  final String id;
  final String nickname;
  @JsonKey(nullable: true)
  final DateTime bannedUntil;
  final DateTime lastActivityAt;
  @JsonKey(
      nullable: true,
      defaultValue: []) // не хочу показывать для items.win.member
  final List<ItemModel> items;

  MemberModel({
    this.id,
    this.nickname,
    this.bannedUntil,
    this.lastActivityAt,
    this.items,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) =>
      _$MemberModelFromJson(json);

  Map<String, dynamic> toJson() => _$MemberModelToJson(this);
}
