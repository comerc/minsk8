import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'image.g.dart';

@JsonSerializable()
class ImageModel {
  final String id;

  ImageModel(this.id);

  imageUrl(size) {
    return 'https://picsum.photos/$size?image=$id';
  }

  factory ImageModel.fromJson(Map<String, dynamic> json) =>
      _$ImageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImageModelToJson(this);
}
