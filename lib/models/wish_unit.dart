import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:minsk8/import.dart';

part 'wish_unit.g.dart';

@JsonSerializable()
class WishUnitModel extends Equatable {
  WishUnitModel({
    // this.updatedAt,
    this.unit,
  });

  // final DateTime updatedAt;
  final UnitModel unit;

  @override
  List<Object> get props => [
        // updatedAt,
        unit,
      ];

  static WishUnitModel fromJson(Map<String, dynamic> json) =>
      _$WishUnitModelFromJson(json);

  Map<String, dynamic> toJson() => _$WishUnitModelToJson(this);
}
