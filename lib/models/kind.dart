class KindModel {
  final value;
  // TODO: как задекларировать "union type"? (MetaKindId | KindId)
  final String name;
  final String rawSvg;

  KindModel(
    this.value,
    this.name,
    this.rawSvg,
  ) : assert([MetaKindId, KindId].contains(value.runtimeType));
}

enum MetaKindId { recent, fan, best, promo, urgent }

enum KindId { technics, garment, for_home, for_kids, books, other, pets }

final allKinds = [
  KindModel(MetaKindId.recent, 'Новое', '<svg />'),
  KindModel(MetaKindId.fan, 'Интересное', '<svg />'),
  KindModel(MetaKindId.best, 'Лучшее', '<svg />'),
  KindModel(MetaKindId.promo, 'Промо', '<svg />'),
  KindModel(MetaKindId.urgent, 'Срочно', '<svg />'),
  ...kinds,
];

final kinds = [
  KindModel(KindId.technics, 'Техника', '<svg />'),
  KindModel(KindId.garment, 'Одежда', '<svg />'),
  KindModel(KindId.for_home, 'Для дома', '<svg />'),
  KindModel(KindId.for_kids, 'Детское', '<svg />'),
  KindModel(KindId.books, 'Книги', '<svg />'),
  KindModel(KindId.other, 'Другое', '<svg />'),
  KindModel(KindId.pets, 'Животные', '<svg />'),
];
