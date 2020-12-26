import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:minsk8/import.dart';

part 'wish.g.dart';

@JsonSerializable()
class WishModel extends Equatable {
  WishModel({
    // this.updatedAt,
    this.unitId,
  });

  // final DateTime updatedAt;
  final String unitId;

  @override
  List<Object> get props => [
        // updatedAt,
        unitId,
      ];

  static WishModel fromJson(Map<String, dynamic> json) =>
      _$WishModelFromJson(json);

  Map<String, dynamic> toJson() => _$WishModelToJson(this);
}
