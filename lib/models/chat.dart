import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'chat.g.dart';

@JsonSerializable()
class ChatModel {
  final ItemModel item;
  final MemberModel companion;
  final List<MessageModel> messages;

  ChatModel(this.item, this.companion, this.messages);

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatModelToJson(this);
}

// TODO: прикрутить flutter_svg + https://www.google.com/get/noto/help/emoji/
