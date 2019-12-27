import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'message.g.dart';

@JsonSerializable()
class MessageModel {
  final String id;
  final String text;
  final bool isMine;

  MessageModel(this.id, this.text, this.isMine);

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);
}

// TODO: прикрутить flutter_svg + https://www.google.com/get/noto/help/emoji/
