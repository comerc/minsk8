import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:minsk8/import.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit(AuthenticationRepository repository)
      : assert(repository != null),
        _repository = repository,
        super(AuthenticationState.unknown()) {
    _userSubscription = repository.user.listen(changeUser);
  }

  final AuthenticationRepository _repository;
  StreamSubscription<UserModel> _userSubscription;

  @override
  Future<void> close() async {
    await _userSubscription.cancel();
    return super.close();
  }

  void changeUser(UserModel user) {
    final result = user == UserModel.empty
        ? AuthenticationState.unauthenticated()
        : AuthenticationState.authenticated(user);
    emit(result);
  }

  void requestLogout() {
    _repository.logOut();
  }
}

// class AuthenticationBloc
//     extends Bloc<AuthenticationEvent, AuthenticationState> {
//   AuthenticationBloc({
//     @required AuthenticationRepository authenticationRepository,
//   })  : assert(authenticationRepository != null),
//         _authenticationRepository = authenticationRepository,
//         super(AuthenticationState.unknown()) {
//     _userSubscription = _authenticationRepository.user.listen(
//       (user) => add(AuthenticationUserChanged(user)),
//     );
//   }

//   final AuthenticationRepository _authenticationRepository;
//   StreamSubscription<UserModel> _userSubscription;

//   @override
//   Stream<AuthenticationState> mapEventToState(
//     AuthenticationEvent event,
//   ) async* {
//     if (event is AuthenticationUserChanged) {
//       yield _mapAuthenticationUserChangedToState(event);
//     } else if (event is AuthenticationLogoutRequested) {
//       unawaited(_authenticationRepository.logOut());
//     }
//   }

//   @override
//   Future<void> close() {
//     _userSubscription?.cancel();
//     return super.close();
//   }

//   AuthenticationState _mapAuthenticationUserChangedToState(
//     AuthenticationUserChanged event,
//   ) {
//     return event.user != UserModel.empty
//         ? AuthenticationState.authenticated(event.user)
//         : AuthenticationState.unauthenticated();
//   }
// }

// abstract class AuthenticationEvent extends Equatable {
//   AuthenticationEvent();

//   @override
//   List<Object> get props => [];
// }

// class AuthenticationUserChanged extends AuthenticationEvent {
//   AuthenticationUserChanged(this.user);

//   final UserModel user;

//   @override
//   List<Object> get props => [user];
// }

// class AuthenticationLogoutRequested extends AuthenticationEvent {}

enum AuthenticationStatus { authenticated, unauthenticated, unknown }

class AuthenticationState extends Equatable {
  const AuthenticationState._({
    this.status = AuthenticationStatus.unknown,
    this.user = UserModel.empty,
  });

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated(UserModel user)
      : this._(status: AuthenticationStatus.authenticated, user: user);

  const AuthenticationState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  final AuthenticationStatus status;
  final UserModel user;

  @override
  List<Object> get props => [status, user];
}
