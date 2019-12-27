import 'package:json_annotation/json_annotation.dart';
import 'package:latlong/latlong.dart';
import 'package:minsk8/import.dart';

part 'item.g.dart';

@JsonSerializable()
class ItemModel {
  final String id;
  final String text;
  final MemberModel member;
  final List<ImageModel> images;
  final DateTime expiresAt;
  final Urgent urgent;
  final int bid;
  final double locationLatitude;
  final double locationLongitude;

  ItemModel(
    this.id,
    this.text,
    this.member,
    this.images,
    this.expiresAt,
    this.urgent,
    this.bid,
    this.locationLatitude,
    this.locationLongitude,
  );

  factory ItemModel.fromJson(Map<String, dynamic> json) =>
      _$ItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItemModelToJson(this);
}

enum Urgent { very_urgent, urgent, not_urgent, none }
