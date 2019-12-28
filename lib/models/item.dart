import 'package:json_annotation/json_annotation.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:latlong/latlong.dart';
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
  @JsonKey(fromJson: _urgentFromJson, toJson: _urgentToJson)
  final Urgent urgent;
  @JsonKey(nullable: true)
  final int bid;
  @JsonKey(fromJson: _locationFromJson, toJson: _locationToJson)
  final LatLng location;
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
    this.location,
    this.isBlocked,
  );

  static _urgentFromJson(String json) =>
      EnumToString.fromString(Urgent.values, json);
  static _urgentToJson(Urgent urgent) => EnumToString.parse(urgent);

  static _locationFromJson(Map<String, double> json) =>
      LatLng(json['latitude'], json['longitude']);
  static _locationToJson(LatLng location) =>
      {'latitude': location.latitude, 'longitude': location.longitude};

  factory ItemModel.fromJson(Map<String, dynamic> json) =>
      _$ItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItemModelToJson(this);
}

enum Urgent { very_urgent, urgent, not_urgent, none }
