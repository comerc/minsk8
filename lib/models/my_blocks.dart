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

  void updateBlock(int index, BlockModel block, bool isBlocked) {
    if (isBlocked) {
      if (index == -1) {
        blocks.add(block);
        notifyListeners();
      }
    } else {
      if (index != -1) {
        blocks.removeAt(index);
        notifyListeners();
      }
    }
  }

  factory MyBlocksModel.fromJson(Map<String, dynamic> json) =>
      _$MyBlocksModelFromJson(json);

  Map<String, dynamic> toJson() => _$MyBlocksModelToJson(this);
}
