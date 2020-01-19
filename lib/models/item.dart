import 'package:json_annotation/json_annotation.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:latlong/latlong.dart';
import 'package:minsk8/import.dart';

part 'item.g.dart';

@JsonSerializable()
class ItemModel {
  final String id;
  final DateTime createdAt;
  final String text;
  @JsonKey(nullable: true) // надо для items.member.items и profile.member.items
  final MemberModel member;
  final List<ImageModel> images;
  @JsonKey(nullable: true)
  final DateTime expiresAt;
  @JsonKey(nullable: true)
  final int price;
  @JsonKey(fromJson: _urgentFromString, toJson: _urgentToString)
  final UrgentStatus urgent;
  @JsonKey(fromJson: _locationFromJson, toJson: _locationToJson)
  final LatLng location;
  @JsonKey(nullable: true)
  final bool isBlocked;
  @JsonKey(nullable: true)
  final WinModel win;
  @JsonKey(nullable: true)
  final DateTime transferredAt;
  final List<WishModel> wishes;
  @JsonKey(nullable: true)
  final bool isPromo;

  ItemModel({
    this.id,
    this.createdAt,
    this.text,
    this.member,
    this.images,
    this.expiresAt,
    this.urgent,
    this.price,
    this.location,
    this.isBlocked,
    this.win,
    this.transferredAt,
    this.wishes,
    this.isPromo,
  }) : assert(images.length > 0);

  bool get isClosed {
    if (isBlocked ?? false) {
      return true;
    } else if (win != null) {
      return true;
    } else if (expiresAt != null) {
      final seconds =
          CountdownTimer.getSeconds(expiresAt.millisecondsSinceEpoch);
      if (seconds < 1) {
        return true;
      }
    }
    return false;
  }

  static _urgentFromString(String value) =>
      EnumToString.fromString(UrgentStatus.values, value);

  static _urgentToString(UrgentStatus urgent) => EnumToString.parse(urgent);

  static _locationFromJson(Map<String, dynamic> json) {
    final array = json['coordinates'];
    return LatLng(array[0], array[1]);
  }

  static _locationToJson(LatLng location) {
    return {
      'type': 'Point',
      'crs': {
        'type': 'name',
        'properties': {'name': 'urn:ogc:def:crs:EPSG::4326'},
      },
      'coordinates': [location.latitude, location.longitude],
    };
  }

  factory ItemModel.fromJson(Map<String, dynamic> json) =>
      _$ItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItemModelToJson(this);
}
