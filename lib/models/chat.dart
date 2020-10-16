import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'chat.g.dart';

@JsonSerializable()
class ChatModel {
  ChatModel({
    this.unit,
    this.companion,
    this.messages,
    this.isUnitOwnerWritesNow,
    this.isCompanionWritesNow,
    this.updatedAt,
    this.stage,
    this.transactionId,
    this.unitOwnerReadCount,
    this.companionReadCount,
  });

  final UnitModel unit;
  final MemberModel companion;
  final List<MessageModel> messages;
  final bool isUnitOwnerWritesNow;
  final bool isCompanionWritesNow;
  // TODO: updatedAt - как в gmail, обновленные элементы в ChatList нужно переставлять на клиенте
  final DateTime updatedAt;
  final StageValue stage;
  final String transactionId;
  final int unitOwnerReadCount;
  final int companionReadCount;

  String get id => '${unit.id} ${companion.id}';

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatModelToJson(this);
}

// TODO: [MVP] почему значение в messageText для .ready синим цветом - это ссылка?
// TODO: [MVP] какое значение в messageText для .success

enum StageValue {
  ready,
  cancel,
  success,
}
