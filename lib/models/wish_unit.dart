import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:minsk8/import.dart';

part 'wish_unit.g.dart';

@JsonSerializable()
class WishUnitModel extends Equatable {
  WishUnitModel({
    this.unit,
    // this.updatedAt,
  });

  final UnitModel unit;
  // final DateTime updatedAt;

  @override
  List<Object> get props => [
        unit,
        // updatedAt,
      ];

  static WishUnitModel fromJson(Map<String, dynamic> json) =>
      _$WishUnitModelFromJson(json);

  Map<String, dynamic> toJson() => _$WishUnitModelToJson(this);
}
