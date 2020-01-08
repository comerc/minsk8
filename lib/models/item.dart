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
  final MemberModel member;
  final List<ImageModel> images;
  @JsonKey(nullable: true)
  final DateTime expiresAt;
  @JsonKey(nullable: true)
  final int price;
  @JsonKey(fromJson: _urgentFromString, toJson: _urgentToString)
  final UrgentId urgent;
  @JsonKey(fromJson: _locationFromJson, toJson: _locationToJson)
  final LatLng location;
  @JsonKey(nullable: true)
  final bool isBlocked;
  @JsonKey(nullable: true)
  final WinModel win;
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
    this.wishes,
    this.isPromo,
  }) : assert(images.length > 0);

  get status {
    // TODO: реализовать бизнес-логику отображения, учитывая поля:
    // urgent, expiresAt, isBlocked, win.createdAt
    return urgent;
  }

  static _urgentFromString(String value) =>
      EnumToString.fromString(UrgentId.values, value);

  static _urgentToString(UrgentId urgent) => EnumToString.parse(urgent);

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
