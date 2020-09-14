import 'package:minsk8/import.dart';

class KindModel implements EnumModel {
  KindModel(value, String name, this.rawSvg, {this.isNew})
      : assert([MetaKindValue, KindValue].contains(value.runtimeType)),
        _value = value,
        _name = name;

  final _value;
  final String _name;
  final String rawSvg;
  final bool isNew;

  // TODO: как задекларировать "union type"? (MetaKindValue | KindValue)
  // смотрел https://pub.dev/packages/union - не нравится
  // ожидаю https://github.com/dart-lang/language/issues/83
  @override
  dynamic get value => _value;
  @override
  String get name => _name;
}

enum MetaKindValue { recent, fan, best, promo, urgent }

enum KindValue {
  technics,
  garment,
  eat,
  service,
  rarity,
  for_home,
  for_kids,
  books,
  other,
  pets
}

final kAllKinds = <EnumModel>[
  KindModel(MetaKindValue.recent, 'Новое', '<svg />'),
  KindModel(MetaKindValue.fan, 'Интересное', '<svg />'),
  KindModel(MetaKindValue.best, 'Лучшее', '<svg />'),
  KindModel(MetaKindValue.promo, 'Промо', '<svg />'),
  KindModel(MetaKindValue.urgent, 'Срочно', '<svg />'),
  ...kKinds,
];

final kKinds = <KindModel>[
  KindModel(KindValue.technics, 'Техника', '<svg />'),
  KindModel(KindValue.garment, 'Одежда', '<svg />'),
  KindModel(KindValue.eat, 'Еда', '<svg />', isNew: true),
  KindModel(KindValue.service, 'Услуги', '<svg />', isNew: true),
  KindModel(KindValue.rarity, 'Раритет', '<svg />', isNew: true),
  KindModel(KindValue.for_home, 'Для дома', '<svg />'),
  KindModel(KindValue.for_kids, 'Детское', '<svg />'),
  KindModel(KindValue.books, 'Книги', '<svg />'),
  KindModel(KindValue.other, 'Другое', '<svg />'),
  KindModel(KindValue.pets, 'Животные', '<svg />'),
];
