import 'package:json_annotation/json_annotation.dart';
// import 'package:enum_to_string/enum_to_string.dart';
import 'package:latlong/latlong.dart';
import 'package:minsk8/import.dart';

part 'unit.g.dart';

// TODO: зачем было нужно поле want_start_at? (вероятно Flutter #270)

@JsonSerializable()
class UnitModel {
  UnitModel({
    this.id,
    this.createdAt,
    this.text,
    this.member,
    this.images,
    this.expiresAt,
    this.urgent,
    this.price,
    this.location,
    this.address,
    this.isBlocked,
    this.win,
    this.transferredAt,
    this.wishes,
    this.isPromo,
  }) : assert(images.isNotEmpty);

  final String id;
  final DateTime createdAt;
  final String text;
  @JsonKey(nullable: true) // надо для units.member.units и profile.member.units
  final MemberModel member;
  final List<ImageModel> images;
  @JsonKey(nullable: true)
  final DateTime expiresAt;
  @JsonKey(nullable: true)
  final int price;
  // @JsonKey(fromJson: _urgentFromString, toJson: _urgentToString)
  final UrgentValue urgent;
  @JsonKey(fromJson: _locationFromJson, toJson: _locationToJson)
  final LatLng location;
  @JsonKey(nullable: true)
  final String address;
  @JsonKey(nullable: true)
  final bool isBlocked;
  @JsonKey(nullable: true)
  final WinModel win;
  @JsonKey(nullable: true)
  final DateTime transferredAt;
  final List<WishModel> wishes;
  @JsonKey(nullable: true)
  final bool isPromo;

  bool get isClosed {
    // описание состояний - смотри комменты в диалогах WantButton
    if (isBlockedOrLocalDeleted) {
      return true;
    } else if (win != null) {
      return true;
    } else if (isExpired) {
      return true;
    }
    return false;
  }

  bool get isExpired {
    if (expiresAt != null) {
      final seconds =
          CountdownTimer.getSeconds(expiresAt.millisecondsSinceEpoch);
      if (seconds < 1) {
        return true;
      }
    }
    return false;
  }

  dynamic meta;

  // static UrgentValue _urgentFromString(String value) =>
  //     EnumToString.fromString(UrgentValue.values, value);

  // static String _urgentToString(UrgentValue urgent) =>
  //     EnumToString.parse(urgent);

  static LatLng _locationFromJson(Map<String, dynamic> json) {
    final array = json['coordinates'];
    return LatLng(array[0] as double, array[1] as double);
  }

  static Map<String, dynamic> _locationToJson(LatLng location) {
    return {
      'type': 'Point',
      'crs': {
        'type': 'name',
        'properties': {'name': 'urn:ogc:def:crs:EPSG::4326'},
      },
      'coordinates': [location.latitude, location.longitude],
    };
  }

  bool get isLocalDeleted => localDeletedUnitIds.contains(id);
  bool get isBlockedOrLocalDeleted => (isBlocked ?? false) || isLocalDeleted;

  String get avatarUrl => images[0].getDummyUrl(id);

  factory UnitModel.fromJson(Map<String, dynamic> json) =>
      _$UnitModelFromJson(json);

  Map<String, dynamic> toJson() => _$UnitModelToJson(this);
}
