import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'chat.g.dart';

@JsonSerializable()
class ChatModel {
  final ItemModel item;
  final MemberModel companion;
  final List<MessageModel> messages;
  final bool isItemOwnerWritesNow;
  final bool isCompanionWritesNow;
  final bool isItemOwnerReadAll;
  final bool isCompanionReadAll;

  ChatModel(
    this.item,
    this.companion,
    this.messages,
    this.isItemOwnerWritesNow,
    this.isCompanionWritesNow,
    this.isItemOwnerReadAll,
    this.isCompanionReadAll,
  );

  get id => '${item.id} ${companion.id}';

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatModelToJson(this);
}
