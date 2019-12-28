import 'package:json_annotation/json_annotation.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:minsk8/import.dart';

part 'item.g.dart';

@JsonSerializable()
class ItemModel {
  final String id;
  final String text;
  final MemberModel member;
  final List<ImageModel> images;
  @JsonKey(nullable: true)
  final DateTime expiresAt;
  @JsonKey(fromJson: _urgentFromString, toJson: _urgentToString)
  final Urgent urgent;
  @JsonKey(nullable: true)
  final int bid;
  final double locationLatitude;
  final double locationLongitude;
  @JsonKey(nullable: true)
  final bool isBlocked;

  ItemModel(
    this.id,
    this.text,
    this.member,
    this.images,
    this.expiresAt,
    this.urgent,
    this.bid,
    this.locationLatitude,
    this.locationLongitude,
    this.isBlocked,
  );

  static _urgentFromString(String value) =>
      EnumToString.fromString(Urgent.values, value);
  static _urgentToString(Urgent value) => EnumToString.parse(value);

  factory ItemModel.fromJson(Map<String, dynamic> json) =>
      _$ItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItemModelToJson(this);
}

enum Urgent { very_urgent, urgent, not_urgent, none }
