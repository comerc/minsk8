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
      ));
    } catch (error) {
      // TODO: [MVP] исправить на catch (error), иначе не перехватываются Error
      emit(state.copyWith(status: ProfileStatus.error));
      rethrow;
    }
    emit(state.copyWith(status: ProfileStatus.ready));
  }

  Future<void> addUnitLocaly(UnitModel unit) async {
    final units = state.profile.member.units.toList()..insert(0, unit);
    final member = state.profile.member.copyWith(units: units.toBuiltList());
    final profile = state.profile.copyWith(member: member);
    emit(state.copyWith(profile: profile));
  }

  void _updateWishLocaly(WishData data, WishModel wish) {
    final wishes = state.profile.wishes.toList();
    final index = state.profile.getWishIndex(data.unitId);
    bool isChanged = false;
    if (data.value) {
      if (index == -1) {
        wishes.add(wish);
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

  Future<void> saveWish(WishData data) async {
    //     final oldUpdatedAt = index == -1 ? null : wishes[index].updatedAt;
    //     final wish = WishModel(
    //       updatedAt: updatedAt ?? DateTime.now(),
    //       unitId: unitId,
    //     );
    // TODO: (?) преобразовывать дату, которую присваиваю на клиенте в .toUtc()
    final wish = await _repository.upsertWish(data);
    _updateWishLocaly(data, wish);
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

@JsonSerializable(createFactory: false)
class WishData {
  WishData({this.unitId, this.value});

  final String unitId;
  final bool value;

  Map<String, dynamic> toJson() => _$WishDataToJson(this);
}
