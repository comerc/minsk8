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
  @JsonKey(nullable: true)
  final int price;
  @JsonKey(fromJson: _urgentFromString, toJson: _urgentToString)
  final Urgent urgent;
  @JsonKey(fromJson: _locationFromString, toJson: _locationToString)
  final LatLng location;
  @JsonKey(nullable: true)
  final bool isBlocked;
  @JsonKey(nullable: true)
  final TotalWishesModel totalWishes;

  ItemModel(
    this.id,
    this.text,
    this.member,
    this.images,
    this.expiresAt,
    this.urgent,
    this.price,
    this.location,
    this.isBlocked,
    this.totalWishes,
  );

  get status {
    // TODO: реализовать бизнес-логику отображения (лучше на backend-е), учитывая поля:
    // urgent, expires_at, is_blocked, winner_member_id
    return urgent;
  }

  static _urgentFromString(String value) =>
      EnumToString.fromString(Urgent.values, value);

  static _urgentToString(Urgent urgent) => EnumToString.parse(urgent);

  static _locationFromString(value) {
    final array = value.split(',');
    return LatLng(array[0], array[1]);
  }

  static _locationToString(LatLng location) =>
      '${location.latitude},${location.longitude}';

  factory ItemModel.fromJson(Map<String, dynamic> json) =>
      _$ItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItemModelToJson(this);
}

enum Urgent { very_urgent, urgent, not_urgent, none }
