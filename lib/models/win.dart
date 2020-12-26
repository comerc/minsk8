import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'win.g.dart';

@JsonSerializable()
class WinModel extends Equatable {
  WinModel({
    this.member,
    this.createdAt,
  });

  @JsonKey(nullable: true) // надо для profile.member.bids.win
  final MemberModel member;
  final DateTime createdAt;

  @override
  List<Object> get props => [
        member,
        createdAt,
      ];

  static WinModel fromJson(Map<String, dynamic> json) =>
      _$WinModelFromJson(json);

  Map<String, dynamic> toJson() => _$WinModelToJson(this);
}
