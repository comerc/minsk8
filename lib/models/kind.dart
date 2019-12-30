// import 'package:json_annotation/json_annotation.dart';
// import 'package:minsk8/import.dart';

class KindModel {
  final dynamic id;
  final String name;
  final String rawSvg;

  KindModel(
    this.id,
    this.name,
    this.rawSvg,
  );
}

enum MetaKindId { all, interesting, best, promo, urgent }

enum KindId { technics, garment, for_home, for_kids, books, other, pets }

final kinds = [
  KindModel(MetaKindId.all, 'Все', '<svg />'),
  KindModel(MetaKindId.interesting, 'Интересное', '<svg />'),
  KindModel(MetaKindId.best, 'Лучшее', '<svg />'),
  KindModel(MetaKindId.promo, 'Промо', '<svg />'),
  KindModel(MetaKindId.urgent, 'Срочно', '<svg />'),
  KindModel(KindId.technics, 'Техника', '<svg />'),
  KindModel(KindId.garment, 'Одежда', '<svg />'),
  KindModel(KindId.for_home, 'Для дома', '<svg />'),
  KindModel(KindId.for_kids, 'Детское', '<svg />'),
  KindModel(KindId.books, 'Книги', '<svg />'),
  KindModel(KindId.other, 'Другое', '<svg />'),
  KindModel(KindId.pets, 'Животные', '<svg />'),
];
