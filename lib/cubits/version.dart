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
      String packageValue;
      if (state.packageValue == null) {
        final packageInfo = await PackageInfo.fromPlatform();
        packageValue = '${packageInfo.version}+${packageInfo.buildNumber}';
      }
      await _remoteConfig.fetch(expiration: kRemoteConfigExpiration);
      await _remoteConfig.activateFetched();
      final releaseValue = _remoteConfig.getString('release_value');
      final supportValue = _remoteConfig.getString('support_value');
      emit(state.copyWith(
        packageValue: packageValue,
        releaseValue: releaseValue,
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
    this.packageValue,
    this.releaseValue,
    this.supportValue,
    this.status = VersionStatus.initial,
  });

  final String packageValue;
  final String releaseValue;
  final String supportValue;
  final VersionStatus status;

  @override
  List<Object> get props => [
        packageValue,
        releaseValue,
        supportValue,
        status,
      ];

  bool get isValidPackageValue =>
      supportValue != null &&
      supportValue.isNotEmpty &&
      packageValue != null &&
      Version.parse(supportValue) <= Version.parse(packageValue);

  // TODO: добавить модальный диалог необязательного обновления (сейчас есть только блокирующее)
  bool get hasUpdate =>
      Version.parse(releaseValue) > Version.parse(packageValue);
}
