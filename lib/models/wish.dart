import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
// import 'package:minsk8/import.dart';

part 'wish.g.dart';

@JsonSerializable()
class WishModel extends Equatable {
  WishModel({
    this.unitId,
    // this.updatedAt,
  });

  final String unitId;
  // final DateTime updatedAt;

  @override
  List<Object> get props => [
        unitId,
        // updatedAt,
      ];

  static WishModel fromJson(Map<String, dynamic> json) =>
      _$WishModelFromJson(json);

  Map<String, dynamic> toJson() => _$WishModelToJson(this);
}
