import 'package:json_annotation/json_annotation.dart';
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

  static UnitModel fromJson(Map<String, dynamic> json) =>
      _$UnitModelFromJson(json);

  Map<String, dynamic> toJson() => _$UnitModelToJson(this);
}

enum UrgentValue {
  @JsonValue('very_urgent')
  veryUrgent,
  urgent,
  @JsonValue('not_urgent')
  notUrgent,
  none,
}

String getUrgentName(UrgentValue value) {
  final map = {
    UrgentValue.veryUrgent: 'Очень срочно',
    UrgentValue.urgent: 'Срочно',
    UrgentValue.notUrgent: 'Не срочно',
    UrgentValue.none: 'Совсем не срочно',
  };
  assert(UrgentValue.values.length == map.length);
  return map[value];
}

String getUrgentText(UrgentValue value) {
  final map = {
    UrgentValue.veryUrgent: 'Сегодня-завтра',
    UrgentValue.urgent: 'Ближайшие дни',
    UrgentValue.notUrgent: 'Ближайшую неделю',
    UrgentValue.none: 'Выгодно для ценных лотов',
  };
  assert(UrgentValue.values.length == map.length);
  return map[value];
}

enum MetaKindValue {
  recent,
  fan,
  best,
  promo,
  urgent,
}

String getMetaKindName(MetaKindValue value) {
  final map = {
    MetaKindValue.recent: 'Новое',
    MetaKindValue.fan: 'Интересное',
    MetaKindValue.best: 'Лучшее',
    MetaKindValue.promo: 'Промо',
    MetaKindValue.urgent: 'Срочно',
  };
  assert(MetaKindValue.values.length == map.length);
  return map[value];
}

enum KindValue {
  technics,
  garment,
  eat,
  service,
  rarity,
  @JsonValue('for_home')
  forHome,
  @JsonValue('for_kids')
  forKids,
  books,
  other,
  pets,
}

String getKindName(KindValue value) {
  final map = {
    KindValue.technics: 'Техника',
    KindValue.garment: 'Одежда',
    KindValue.eat: 'Еда',
    KindValue.service: 'Услуги',
    KindValue.rarity: 'Раритет',
    KindValue.forHome: 'Для дома',
    KindValue.forKids: 'Детское',
    KindValue.books: 'Книги',
    KindValue.other: 'Другое',
    KindValue.pets: 'Животные',
  };
  assert(KindValue.values.length == map.length);
  return map[value];
}

bool isNewKind(KindValue value) {
  return [
    KindValue.eat,
    KindValue.service,
    KindValue.rarity,
  ].contains(value);
}
