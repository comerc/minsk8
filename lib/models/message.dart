import 'package:json_annotation/json_annotation.dart';
import 'package:enum_to_string/enum_to_string.dart';
// import 'package:minsk8/import.dart';

part 'message.g.dart';

@JsonSerializable()
class MessageModel {
  final String id;
  final String text;
  @JsonKey(fromJson: _authorFromString, toJson: _authorToString)
  final MessageAuthor author;
  final bool isRead;
  final DateTime createdAt;

  MessageModel({
    this.id,
    this.text,
    this.author,
    this.isRead,
    this.createdAt,
  });

  static MessageAuthor _authorFromString(String value) =>
      EnumToString.fromString(MessageAuthor.values, value);

  static String _authorToString(MessageAuthor author) =>
      EnumToString.parse(author);

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);
}

enum MessageAuthor { item_owner, companion }

// TODO: прикрутить flutter_svg + https://www.google.com/get/noto/help/emoji/
