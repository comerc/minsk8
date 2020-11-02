import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'member.g.dart';

@JsonSerializable()
class MemberModel {
  MemberModel({
    this.id,
    this.displayName,
    this.photoUrl,
    this.bannedUntil,
    this.lastActivityAt,
    this.units,
  });

  final String id;
  final String displayName;
  @JsonKey(nullable: true)
  final String photoUrl;
  @JsonKey(nullable: true)
  final DateTime bannedUntil;
  final DateTime lastActivityAt;
  @JsonKey(
      nullable: true,
      defaultValue: []) // не хочу показывать для units.win.member, payments.inviteMember
  final List<UnitModel> units;

  // TODO: если null, то рисовать цветной кружок с инициалами, как в телеге
  String get avatarUrl => photoUrl ?? 'https://robohash.org/$id?set=set4';

  factory MemberModel.fromJson(Map<String, dynamic> json) =>
      _$MemberModelFromJson(json);
}
