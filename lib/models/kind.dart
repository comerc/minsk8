import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'kind.g.dart';

@JsonSerializable()
class KindModel {
  final String id;
  final String name;
  final String rawSvg;

  KindModel(this.id, this.name, this.rawSvg);

  factory KindModel.fromJson(Map<String, dynamic> json) =>
      _$KindModelFromJson(json);

  Map<String, dynamic> toJson() => _$KindModelToJson(this);
}

enum MetaKindId { all, interesting, best, promo, urgent }
