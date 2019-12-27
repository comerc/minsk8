import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'kind.g.dart';

@JsonSerializable()
class KindModel {
  final String id;
  final String name;
  final int order;

  KindModel(this.id, this.name, this.order);

  factory KindModel.fromJson(Map<String, dynamic> json) =>
      _$KindModelFromJson(json);

  Map<String, dynamic> toJson() => _$KindModelToJson(this);
}
