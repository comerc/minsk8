import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'image.g.dart';

// TODO: [MVP] Building Image CDN with Firebase
// https://dev.to/dbanisimov/building-image-cdn-with-firebase-15ef

@JsonSerializable()
class ImageModel extends Equatable {
  ImageModel({
    this.url,
    this.width,
    this.height,
  });

  final String url;
  final int width;
  final int height;

  String getDummyUrl(String id) {
    final urlHash = generateMd5(url + id);
    return 'https://picsum.photos/seed/$urlHash/${width ~/ 4}/${height ~/ 4}'; // TODO: url
  }

  String getLargeDummyUrl(String id) {
    return getDummyUrl(id);
  }

  // ImageProvider createNetworkImage() {
  //   return ExtendedNetworkImageProvider(imageUrl);
  // }

  // ImageProvider createResizeImage() {
  //   return ResizeImage(ExtendedNetworkImageProvider(imageUrl),
  //       width: width ~/ 5, height: height ~/ 5);
  // }

  // for SliverListConfig.collectGarbage
  // void clearCache() {
  //   createNetworkImage().evict();
  //   createResizeImage().evict();
  // }

  @override
  List<Object> get props => [
        url,
        width,
        height,
      ];

  static ImageModel fromJson(Map<String, dynamic> json) =>
      _$ImageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImageModelToJson(this);
}
