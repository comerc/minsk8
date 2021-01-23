import 'dart:async';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:version/version.dart';
import 'package:package_info/package_info.dart';
import 'package:minsk8/import.dart';

part 'version.g.dart';

class VersionCubit extends Cubit<VersionState> {
  VersionCubit(RemoteConfig remoteConfig)
      : assert(remoteConfig != null),
        _remoteConfig = remoteConfig,
        super(VersionState());

  final RemoteConfig _remoteConfig;

  Future<void> load() async {
    if (state.status == VersionStatus.loading) return;
    emit(state.copyWith(status: VersionStatus.loading));
    try {
      String currentValue;
      if (state.currentValue == null) {
        final packageInfo = await PackageInfo.fromPlatform();
        currentValue = '${packageInfo.version}+${packageInfo.buildNumber}';
      }
      await _remoteConfig.fetch(expiration: kRemoteConfigExpiration);
      await _remoteConfig.activateFetched();
      final supportValue = _remoteConfig.getString('support_value');
      emit(state.copyWith(
        currentValue: currentValue,
        supportValue: supportValue,
        status: VersionStatus.ready,
      ));
    } catch (error) {
      out(error);
      emit(state.copyWith(status: VersionStatus.error));
      rethrow;
    }
  }
}

enum VersionStatus { initial, loading, error, ready }

@CopyWith()
class VersionState extends Equatable {
  VersionState({
    this.currentValue,
    this.supportValue,
    this.status = VersionStatus.initial,
  });

  final String currentValue;
  final String supportValue;
  final VersionStatus status;

  @override
  List<Object> get props => [
        currentValue,
        supportValue,
        status,
      ];

  bool get isValidCurrentValue =>
      supportValue != null &&
      supportValue.isNotEmpty &&
      currentValue != null &&
      Version.parse(supportValue) <= Version.parse(currentValue);
}
