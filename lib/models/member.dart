import 'package:built_collection/built_collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'member.g.dart';

@CopyWith()
@JsonSerializable()
class MemberModel extends Equatable {
  MemberModel({
    this.id,
    this.displayName,
    this.imageUrl,
    this.bannedUntil,
    this.lastActivityAt,
    this.units,
  });

  final String id;
  final String displayName;
  @JsonKey(nullable: true)
  final String imageUrl;
  @JsonKey(nullable: true)
  final DateTime bannedUntil;
  final DateTime lastActivityAt;
  // не хочу показывать для units.win.member, payments.inviteMember
  @JsonKey(nullable: true)
  final BuiltList<UnitModel> units;

  // TODO: если null, то рисовать цветной кружок с инициалами, как в телеге
  String get avatarUrl => imageUrl ?? 'https://robohash.org/$id?set=set4';

  @override
  List<Object> get props => [
        id,
        displayName,
        imageUrl,
        bannedUntil,
        lastActivityAt,
        units,
      ];

  static MemberModel fromJson(Map<String, dynamic> json) =>
      _$MemberModelFromJson(json);

  Map<String, dynamic> toJson() => _$MemberModelToJson(this);
}
