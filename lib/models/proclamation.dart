import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'proclamation.g.dart';

@JsonSerializable()
class ProclamationModel extends Equatable {
  ProclamationModel({
    this.id,
    this.unit,
    this.text,
  });

  final String id;
  @JsonKey(nullable: true)
  final UnitModel unit;
  final String text;

  @override
  List<Object> get props => [
        id,
        unit,
        text,
      ];

  static ProclamationModel fromJson(Map<String, dynamic> json) =>
      _$ProclamationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProclamationModelToJson(this);
}
