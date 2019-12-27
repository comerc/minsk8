import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'member.g.dart';

// TODO:  https://robohash.org/

@JsonSerializable()
class MemberModel {
  final String id;
  final String nickname;

  MemberModel(this.id, this.nickname);

  factory MemberModel.fromJson(Map<String, dynamic> json) =>
      _$MemberModelFromJson(json);

  Map<String, dynamic> toJson() => _$MemberModelToJson(this);
}
