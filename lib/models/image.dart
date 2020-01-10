import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'image.g.dart';

@JsonSerializable()
class ImageModel {
  final String url;
  final int width;
  final int height;

  ImageModel({
    this.url,
    this.width,
    this.height,
  });

  getDummyUrl(String id) {
    final urlHash = generateMd5(url + id);
    return 'https://picsum.photos/seed/2$urlHash/${width ~/ 4}/${height ~/ 4}'; // TODO: url
  }

  factory ImageModel.fromJson(Map<String, dynamic> json) =>
      _$ImageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImageModelToJson(this);
}
