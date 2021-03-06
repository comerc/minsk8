import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'chat.g.dart';

@JsonSerializable()
class ChatModel extends Equatable {
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
  final BuiltList<MessageModel> messages;
  final bool isUnitOwnerWritesNow;
  final bool isCompanionWritesNow;
  // TODO: updatedAt - как в gmail, обновленные элементы в ChatList нужно переставлять на клиенте
  final DateTime updatedAt;
  final StageValue stage;
  final String transactionId;
  final int unitOwnerReadCount;
  final int companionReadCount;

  String get id => '${unit.id} ${companion.id}';

  @override
  List<Object> get props => [
        unit,
        companion,
        messages,
        isUnitOwnerWritesNow,
        isCompanionWritesNow,
        updatedAt,
        stage,
        transactionId,
        unitOwnerReadCount,
        companionReadCount,
      ];

  static ChatModel fromJson(Map<String, dynamic> json) =>
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

String getStageName(StageValue value) {
  final map = {
    StageValue.ready: 'Договоритесь о встрече',
    StageValue.cancel: 'Отменённые',
    StageValue.success: 'Завершённые',
  };
  assert(StageValue.values.length == map.length);
  return map[value];
}

String getStageText(StageValue value) {
  final map = {
    StageValue.ready: 'Договоритесь о встрече',
    StageValue.cancel: 'Лот отдан другому',
    StageValue.success: 'Лот завершён',
  };
  assert(StageValue.values.length == map.length);
  return map[value];
}
