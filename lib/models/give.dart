import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'give.g.dart';

@JsonSerializable()
class GiveModel extends Equatable {
  GiveModel({
    this.unit,
    // this.createdAt,
  });

  final UnitModel unit;
  // final DateTime createdAt;

  @override
  List<Object> get props => [
        unit,
        // createdAt,
      ];

  static GiveModel fromJson(Map<String, dynamic> json) =>
      _$GiveModelFromJson(json);

  Map<String, dynamic> toJson() => _$GiveModelToJson(this);
}
