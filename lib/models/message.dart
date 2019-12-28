import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'message.g.dart';

@JsonSerializable()
class MessageModel {
  final String id;
  final String text;
  final String fromMemberId;
  final String toMemberId;
  final DateTime createdAt;

  MessageModel(
      this.id, this.text, this.fromMemberId, this.toMemberId, this.createdAt);

  isMine(String fromMemberId) {
    return fromMemberId == toMemberId;
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);
}

// TODO: прикрутить flutter_svg + https://www.google.com/get/noto/help/emoji/
