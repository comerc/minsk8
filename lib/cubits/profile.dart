import 'dart:async';
import 'package:json_annotation/json_annotation.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:minsk8/import.dart';

part 'profile.g.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(DatabaseRepository repository)
      : assert(repository != null),
        _repository = repository,
        super(ProfileState());

  final DatabaseRepository _repository;

  Future<void> load(MemberData data) async {
    if (state.status == ProfileStatus.loading) return;
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final memberId = await _repository.upsertMember(data);
      emit(state.copyWith(
        profile: await _repository.readProfile(memberId),
        status: ProfileStatus.ready,
      ));
    } catch (_) {
      // TODO: [MVP] исправить на catch (error), иначе не перехватываются Error
      emit(state.copyWith(status: ProfileStatus.error));
      rethrow;
    }
  }

  Future<void> addUnitLocaly(UnitModel unit) async {
    final units = state.profile.member.units.toList()..insert(0, unit);
    final member = state.profile.member.copyWith(units: units.toBuiltList());
    final profile = state.profile.copyWith(member: member);
    emit(state.copyWith(profile: profile));
  }

  void _updateWishLocaly(WishData data) {
    final wishes = state.profile.wishes.toList();
    final index = state.profile.getWishIndex(data.unitId);
    var isChanged = false;
    if (data.value) {
      if (index == -1) {
        wishes.add(WishModel(unitId: data.unitId));
        isChanged = true;
      }
    } else {
      if (index != -1) {
        wishes.removeAt(index);
        isChanged = true;
      }
    }
    if (isChanged) {
      final profile = state.profile.copyWith(wishes: wishes.toBuiltList());
      emit(state.copyWith(profile: profile));
    }
  }

  Future<void> _queueSaveWish = Future.value();

  Future<void> saveWish(WishData data) {
    _updateWishLocaly(data);
    _queueSaveWish = _queueSaveWish.catchError((_) => null);
    _queueSaveWish = _queueSaveWish.then((_) async {
      try {
        await _repository.upsertWish(data);
      } catch (_) {
        _updateWishLocaly(data.copyWith(value: !data.value));
        rethrow;
      }
    });
    return _queueSaveWish;
  }

  void _updateBlockLocaly(BlockData data) {
    final blocks = state.profile.blocks.toList();
    final index = state.profile.getBlockIndex(data.memberId);
    var isChanged = false;
    if (data.value) {
      if (index == -1) {
        blocks.add(BlockModel(memberId: data.memberId));
        isChanged = true;
      }
    } else {
      if (index != -1) {
        blocks.removeAt(index);
        isChanged = true;
      }
    }
    if (isChanged) {
      final profile = state.profile.copyWith(blocks: blocks.toBuiltList());
      emit(state.copyWith(profile: profile));
    }
  }

  Future<void> _queueSaveBlock = Future.value();

  Future<void> saveBlock(BlockData data) {
    _updateBlockLocaly(data);
    _queueSaveBlock = _queueSaveBlock.catchError((_) => null);
    _queueSaveBlock = _queueSaveBlock.then((_) async {
      try {
        await _repository.upsertBlock(data);
      } catch (_) {
        _updateBlockLocaly(data.copyWith(value: !data.value));
        rethrow;
      }
    });
    return _queueSaveBlock;
  }
}

enum ProfileStatus { initial, loading, error, ready }

@CopyWith()
class ProfileState extends Equatable {
  ProfileState({
    this.profile,
    this.status = ProfileStatus.initial,
  });

  final ProfileModel profile;
  final ProfileStatus status;

  @override
  List<Object> get props => [
        profile,
        status,
      ];
}

@JsonSerializable(createFactory: false)
class MemberData {
  MemberData({this.displayName, this.imageUrl});

  final String displayName;
  final String imageUrl;

  Map<String, dynamic> toJson() => _$MemberDataToJson(this);
}

@CopyWith()
@JsonSerializable(createFactory: false)
class WishData {
  WishData({this.unitId, this.value});

  final String unitId;
  final bool value;

  Map<String, dynamic> toJson() => _$WishDataToJson(this);
}

@CopyWith()
@JsonSerializable(createFactory: false)
class BlockData {
  BlockData({this.memberId, this.value});

  final String memberId;
  final bool value;

  Map<String, dynamic> toJson() => _$BlockDataToJson(this);
}
