import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:minsk8/import.dart';

part 'my_blocks.g.dart';

@JsonSerializable()
class MyBlocksModel extends ChangeNotifier {
  MyBlocksModel({
    this.blocks,
  });

  final List<BlockModel> blocks;

  int getBlockIndex(String memberId) =>
      blocks.indexWhere((block) => block.memberId == memberId);

  DateTime updateBlock({String memberId, bool value, DateTime updatedAt}) {
    final index = getBlockIndex(memberId);
    final oldUpdatedAt = index == -1 ? null : blocks[index].updatedAt;
    final block = BlockModel(
      updatedAt: updatedAt ?? DateTime.now(),
      memberId: memberId,
    );
    if (value) {
      if (index == -1) {
        blocks.add(block);
      } else {
        blocks[index] = block;
      }
      notifyListeners();
    } else {
      if (index != -1) {
        blocks.removeAt(index);
        notifyListeners();
      }
    }
    return oldUpdatedAt;
  }

  factory MyBlocksModel.fromJson(Map<String, dynamic> json) =>
      _$MyBlocksModelFromJson(json);

  Map<String, dynamic> toJson() => _$MyBlocksModelToJson(this);
}
