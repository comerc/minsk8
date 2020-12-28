import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:minsk8/import.dart';

part 'login.g.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(AuthenticationRepository repository)
      : assert(repository != null),
        _repository = repository,
        super(LoginState());

  final AuthenticationRepository _repository;

  Future<void> logInWithGoogle() async {
    if (state.status == LoginStatus.loading) return;
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      await _repository.logInWithGoogle();
      emit(state.copyWith(status: LoginStatus.ready));
    } catch (_) {
      emit(state.copyWith(status: LoginStatus.error));
      rethrow;
    }
  }
}

enum LoginStatus { initial, loading, error, ready }

@CopyWith()
class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
  });

  final LoginStatus status;

  @override
  List<Object> get props => [status];
}
