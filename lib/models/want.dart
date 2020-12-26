import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'want.g.dart';

@JsonSerializable()
class WantModel extends Equatable {
  WantModel({
    this.unit,
    this.value,
    // this.updatedAt,
    this.win,
  });

  final UnitModel unit;
  final int value;
  // final DateTime updatedAt;
  @JsonKey(nullable: true)
  final WinModel win;

  @override
  List<Object> get props => [
        unit,
        value,
        // updatedAt,
        win,
      ];

  static WantModel fromJson(Map<String, dynamic> json) =>
      _$WantModelFromJson(json);

  Map<String, dynamic> toJson() => _$WantModelToJson(this);
}
