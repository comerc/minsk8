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
    } on Exception {
      // TODO: исправить на catch (error), иначе не перехватываются Error
      emit(state.copyWith(status: ProfileStatus.error));
      rethrow;
    }
    emit(state.copyWith(status: ProfileStatus.ready));
  }

  // Future<void> saveWish(WishData data) async {
  //   final wish = await _repository.upsertWish(data);
  //   final unitId = wish.unit.id;
  //   if (data.value) {
  //     if (state.wishes.indexWhere((WishModel wish) => wish.unit.id == unitId) ==
  //         -1) {
  //       emit(state.copyWith(
  //         wishes: [wish, ...state.wishes],
  //       ));
  //     }
  //   } else {
  //     emit(state.copyWith(
  //       wishes: [...state.wishes]
  //         ..removeWhere((WishModel wish) => wish.unit.id == unitId),
  //     ));
  //   }
  // }
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

// @JsonSerializable(createFactory: false)
// class WishData {
//   WishData({this.unitId, this.value});

//   final String unitId;
//   final bool value;

//   Map<String, dynamic> toJson() => _$WishDataToJson(this);
// }
